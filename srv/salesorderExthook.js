const cds = require('@sap/cds');
const { executeHttpRequest } = require('@sap-cloud-sdk/http-client');
//const RELEVANT_CONDITIONS = ["ZSDP", "VPRS", "QSBP"];
const destination = { destinationName: "SSC_V2_API" };
const approvalDestination = { destinationName: "SSC_V2_Approval" };
const sseDestination = { destinationName: "SSE_Connect" };

// ===== Helper functions  =====
function extractComparablePricing(image = {}) {

    const priceElements = image.priceElements || [];
    const totalValues = image.totalValues || {};

    const getCond = (type) =>
        priceElements.find(pe => pe.conditionType === type);

    const getAllConds = (type) =>
        priceElements.filter(pe => pe.conditionType === type);

    const cost = getCond('QMMC'); // or VPRS

    // Read all ZTOT rows
    const ztotConditions = getAllConds('ZTOT');

    // Consolidate all ZTOT percentages
    const totalDiscountPercent = ztotConditions.reduce((sum, item) => {
        const value = Number(item?.rateAmount?.content ?? 0);
        return sum + value;
    }, 0);

    return {
        sellingPrice: Number(totalValues?.grossAmount?.content ?? 0),
        sellingCurrency: totalValues?.grossAmount?.currencyCode ?? 'SAR',

        costPrice: Number(cost?.calculatedAmount?.content ?? 0),
        costCurrency:
            cost?.calculatedAmount?.currencyCode ??
            cost?.rateAmount?.currencyCode ??
            'SAR',

        // Absolute consolidated discount %
        discountPercent: Math.abs(totalDiscountPercent)
    };
}

function isRelevantPricingChanged(beforeImage = {}, currentImage = {}) {
    const before = extractComparablePricing(beforeImage);
    const current = extractComparablePricing(currentImage);

    return (
        before.sellingPrice !== current.sellingPrice ||
        before.costPrice !== current.costPrice ||
        before.discountPercent !== current.discountPercent
    );
}

function extractHeaderPricing(currentImage = {}) {

    console.log("currentImage.priceElements:", JSON.stringify(currentImage.priceElements));
    // Get single condition 
    const priceElements = currentImage.priceElements || [];
    const totalValues = currentImage.totalValues || {};

    const getCond = (type) =>
        priceElements.find(pe => pe.conditionType === type);

    // Get all matching conditions
    const getAllConds = (type) =>
        priceElements.filter(pe => pe.conditionType === type);

    const cost = getCond('QMMC'); // Cost price
    console.log("cost condition:", cost);

    // Read all ZTOT rows
    const ztotConditions = getAllConds('ZTOT');
    console.log("ztot Conditions:", ztotConditions);

    // Consolidate all percentage values
    const totalDiscountPercent = ztotConditions.reduce((sum, item) => {
        const value = Number(item?.rateAmount?.content ?? 0);
        console.log("totalDiscountPercent:", value);
        return sum + value;
    }, 0);

    return {
        // Selling price from TOTAL VALUES grossAmount
        sellingPrice: totalValues?.grossAmount?.content ?? 0,
        sellingCurrency: totalValues?.grossAmount?.currencyCode ?? 'SAR',

        // Cost price from condition
        costPrice: cost?.calculatedAmount?.content ?? 0,
        costCurrency:
            cost?.calculatedAmount?.currencyCode ??
            cost?.rateAmount?.currencyCode ??
            'SAR',

        // Consolidated ZTOT %
        discountPercent: totalDiscountPercent
    };
}

function findPartyByRole(partyId, role, casePayload) {
    return casePayload?.parties?.find(p =>
        p.role === role
    );
}

async function getOrderEtag(OrderId) {
    try {
        const response = await executeHttpRequest(destination, {
            method: "GET",
            url: `/sap/c4c/api/v1/sales-order-service/salesOrders/${OrderId}?$exclude=items`
        });
        //console.log("Order Response:", response?.data);

        // Read ETag from response headers
        const etag = response?.data?.value?.adminData?.updatedOn ||
            response?.data?.adminData?.updatedOn;
        const payload = response?.data?.value;

        if (!etag) {
            console.error("getorderEtag No ETag found in response!");
        }

        console.log("getSalesOrderEtag Retrieved ETag:", etag);
        return {
            etag,
            payload
        };
    }
    catch (error) {
        console.error(
            "getOrderEtag:",
            error?.response?.data || error.message
        );
        throw error;
    }
}

async function patchOrderExtensions(orderId, etag, payload) {
    try {
        const url =
            `/sap/c4c/api/v1/sales-order-service/salesOrders/${orderId}`;

        const response = await executeHttpRequest(destination, {
            method: "PATCH",
            url,
            headers: {
                "Content-Type": "application/merge-patch+json",
                "If-Match": etag
            },
            data: payload,
            fetchCsrfToken: false
        });
    }
    catch (error) {
        console.error(
            "patchOrderExtensions:",
            error?.response?.data || error.message
        );
        throw error;
    }
}

/**
 * Trigger an SSE push event for ANY Sales Cloud V2 object.
 * @param {string} entity  Object type, e.g. 'SalesOrder', 'Case', 'Lead'
 * @param {string} id      Object display id, e.g. 'SO-1001'
 */
async function triggerSSEEvent(entity, id) {
    try {
        await executeHttpRequest(sseDestination, {
            method: 'POST',
            url: '/send',                                   // (1) push endpoint, not /events
            headers: { 'Content-Type': 'application/json' },
            data: {                                         // (2) shape resolveKey() understands
                type: `com.sap.c4c.${entity}PushEvent`,
                data: { currentImage: { displayId: id } }
            },
            fetchCsrfToken: false
        });
        console.log(`SSE push event triggered for ${entity}:`, id);
    } catch (sseError) {
        console.warn('SSE push event failed (non-blocking):',
            sseError?.response?.data || sseError.message);
    }
}


/**
 * Add party to Sales Order via POST API
 */
async function addSalesOrderParty(orderId, etag, payload) {
    try {
        const url = `/sap/c4c/api/v1/sales-order-service/salesOrders/${orderId}/parties`;

        console.log("Adding Sales Order party payload:", JSON.stringify(payload));

        const response = await executeHttpRequest(destination, {
            method: "POST",
            url,
            headers: {
                "Content-Type": "application/json",
                "If-Match": etag
            },
            data: payload,
            fetchCsrfToken: false
        });

        return response?.data;
    }
    catch (error) {
        console.error(
            "addSalesOrderParty:",
            error?.response?.data || error.message
        );
        throw error;
    }
}

/**
 * Find Sales Manager (Z05) from discount matrix approvers
 * @returns {Promise<{partyId: string, role: string}|null>}
 */
async function findSalesManagerFromDiscountMatrix(currentImage, pricing) {
    const DiscountMatrix = 'automotive.discounts.discountMatrix';

    const rawDiscount = pricing.discountPercent;
    const discountPercent = Math.abs(Number(rawDiscount) || 0);

    const salesOrg = currentImage.businessArea.salesOrganisationDisplayId;
    const distributionChannel = currentImage.businessArea.distributionChannel;
    const division = currentImage.businessArea.division;
    const salesOffice = currentImage.businessArea.salesOfficeDisplayId;

    // Query discount matrix for all approvers
    const approverRules = await SELECT.from(DiscountMatrix)
        .where({ salesOrg, distributionChannel, division, salesOffice, active: true })
        .orderBy("minPercentage asc");

    if (!approverRules.length) {
        return null;
    }

    // Find the approver with role Z05 (Sales Manager)
    const salesManagerRule = approverRules.find(rule => rule.approverPartyRole === "Z05");

    if (!salesManagerRule) {
        return null;
    }

    return {
        partyId: salesManagerRule.approverEmployeeId,
        role: salesManagerRule.approverPartyRole
    };
}

// Case Service helper functions using CDS external service
async function patchCaseExtensions(caseSrv, caseId, etag, payload) {
    await caseSrv.send({
        method: 'PATCH',
        path: `/cases/${caseId}`,
        headers: {
            'If-Match': etag,
            'Content-Type': 'application/merge-patch+json'
        },
        data: payload
    });
}

function mergeCustomEmployees(existingEmployees, newEmployees) {
    // Return only the delta (new/updated employees)
    // The PATCH API with merge-patch+json will handle merging with existing data
    // If partyRole exists, it will be replaced; if not, it will be added
    return newEmployees;
}

async function patchCaseParty(caseSrv, caseId, etag, payload) {
    try {
        const patchPayload = {
            customEmployees: payload
        };
        console.log("patchCaseParty custom employees Body:", JSON.stringify(patchPayload));
        console.log("patchCaseParty custom employees etag:", etag);
        const response = await caseSrv.send({
            method: "PATCH",
            path: `/cases/${caseId}`,
            headers: { 'If-Match': etag, "Content-Type": "application/merge-patch+json" },
            data: patchPayload
        });

        console.log("Custom Employees updated successfully");
    } catch (error) {
        console.error("Patch failed:", error?.response?.data || error.message);
        throw error;
    }
}

async function getCaseEtag(caseSrv, caseId) {
    const path = `/cases/${caseId}`;

    const response = await caseSrv.send({
        method: "GET",
        path,
        headers: { Accept: "application/json" }
    });
    console.log("getCaseEtag response payload", response);

    // Read ETag from response
    const etag = response?.value?.adminData?.updatedOn ||
        response?.adminData?.updatedOn;
    const payload = response?.value;

    if (!etag) {
        console.error("getcaseEtag No ETag found in response!");
    }

    return {
        etag,
        payload
    };
}

async function getSalesQuoteEtag(salesQuoteSrv, quoteId) {
    const path = `/salesQuotes/${quoteId}`;

    const response = await salesQuoteSrv.send({
        method: "GET",
        path,
        headers: { Accept: "application/json" }
    });

    // Read ETag from the payload
    const etag = response?.value?.etag;
    const payload = response?.value;

    if (!etag) {
        console.error("getSalesQuoteEtag No ETag found in response!");
    }

    return {
        etag,
        payload
    };
}

async function getCaseEtagWithRetry(caseSrv, caseId, maxRetries = 5) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            console.log(`getCaseEtag attempt ${attempt} for caseId: ${caseId}`);
            const result = await getCaseEtag(caseSrv, caseId);
            return result;
        } catch (err) {
            const statusCode = err?.response?.status || err?.status;
            const message = err?.response?.data?.error?.message || err.message;
            console.warn(`getCaseEtag failed (attempt ${attempt}): ${message}`);

            if (attempt < maxRetries) {
                let delayMs;

                if (statusCode === 429) {
                    // Check for Retry-After header
                    const retryAfter = err?.response?.headers?.['retry-after'];
                    if (retryAfter) {
                        delayMs = parseInt(retryAfter, 10) * 1000;
                    } else {
                        // Exponential backoff for 429: 2s, 4s, 8s, 16s, 32s
                        delayMs = Math.pow(2, attempt) * 1000;
                    }
                    console.log(`Rate limited (429). Waiting ${delayMs}ms before retry...`);
                } else {
                    // Standard exponential backoff: 1s, 2s, 4s, 8s, 16s
                    delayMs = Math.pow(2, attempt - 1) * 1000;
                }

                await new Promise(resolve => setTimeout(resolve, delayMs));
                continue;
            }

            // All retries exhausted - return null to allow approval process to continue
            console.error(`getCaseEtag failed after ${maxRetries} attempts. Continuing with approval process.`);
            return { etag: null, payload: null };
        }
    }
}

async function getApprovalStepContext(caseId, phaseType = 'PRE') {
    // phaseType: 'PRE' for Pre-VSS Approval, 'POST' for Post-VSS Approval
    const response = await executeHttpRequest(destination, {
        method: "GET",
        url: `/sap/c4c/api/v1/case-flow-service/caseFlows?caseId=${caseId}`
    });
    console.log("Case Flow Response:", response?.data);
    const flows = response.data?.value || [];

    if (!flows.length) {
        throw new Error("No case flow found for case");
    }

    const flow = flows[0];

    for (const phase of flow.phases || []) {
        // Match phase by description containing "Pre" or "Post"
        const isPre = phase.description?.toLowerCase().includes('pre');
        const isPost = phase.description?.toLowerCase().includes('post');

        console.log(`Phase: ${phase.description}, isPre: ${isPre}, isPost: ${isPost}, looking for: ${phaseType}`);

        if ((phaseType === 'PRE' && isPre) || (phaseType === 'POST' && isPost)) {
            for (const step of phase.steps || []) {
                if (step.stepType === "APPROVAL") {
                    console.log(`Found ${phaseType} approval step: phaseId=${phase.id}, stepId=${step.id}`);
                    return {
                        caseFlowId: flow.id,
                        phaseId: phase.id,
                        stepId: step.id,
                        phaseDescription: phase.description,
                        isSubmittedForApproval: step.isSubmittedForApproval,
                        isApprovalWithdrawn: step.isApprovalWithdrawn,
                        status: phase.status,
                        etag: flow.adminData.updatedOn
                    };
                }
            }
        }
    }

    console.warn(`No ${phaseType} approval step found for case ${caseId}`);
    return null;
}

async function submitCaseApproval(
    caseId,
    caseFlowId,
    phaseId,
    stepId,
    etag
) {
    const url =
        `/sap/c4c/api/v1/case-flow-service` +
        `/caseFlows/${caseFlowId}` +
        `/phases/${phaseId}` +
        `/steps/${stepId}`;

    try {
        const payload = {
            status: "IN_PROGRESS",
            isSubmittedForApproval: true,
            isApprovalWithdrawn: false,
            requesterNote: "Submitted via API"
        };

        const response = await executeHttpRequest(
            approvalDestination,
            {
                method: "PATCH",
                url,
                headers: {
                    "Content-Type": "application/merge-patch+json"
                },
                data: payload
            },
            {
                fetchCsrfToken: false
            }
        );

        console.log("Approval submitted successfully");
        console.log("Response:", response.data);
    } catch (error) {
        console.error(
            "Approval submission failed:",
            error?.response?.data || error.message
        );
        throw error;
    }
}

function hasNewLineAdded(beforeImage = {}, currentImage = {}) {
    const beforeItems = beforeImage.items || [];
    const currentItems = currentImage.items || [];

    console.log("currentImage items:", currentImage.items);

    const beforeIds = new Set(beforeItems.map(item => item.id));

    for (const item of currentItems) {
        if (!beforeIds.has(item.id)) {
            console.log("hasNewLineAdded:", true);
            return true; // New item detected
        }
    }

    return false;
}

function getHeaderDiscount(image = {}) {
    const priceElements = image.priceElements || [];

    // Get all ZTOT conditions
    const ztotConditions = priceElements.filter(pe =>
        pe.conditionType === "ZTOT"
    );

    // Sum all percentage values
    return ztotConditions.reduce((sum, item) => {
        const value = Number(item?.rateAmount?.content ?? 0);
        return sum + value;
    }, 0);
}

async function getUserById(employeeId) {
    const response = await executeHttpRequest(
        destination,
        {
            method: 'GET',
            url: `/sap/c4c/api/v1/iam-service/users?$filter=employeeId eq '${employeeId}'`
        }
    );

    return response?.data?.value?.[0];
}

function isDiscountChanged(beforeImage = {}, currentImage = {}) {
    const beforeDiscount = getHeaderDiscount(beforeImage);
    console.log("beforeDiscount:", beforeDiscount);
    const currentDiscount = getHeaderDiscount(currentImage);
    console.log("currentDiscount:", currentDiscount);
    return beforeDiscount !== currentDiscount;
}

async function withdrawCaseApproval(caseId,
    caseFlowId,
    phaseId,
    stepId,
    etag) {
    try {
        const url =
            `/sap/c4c/api/v1/case-flow-service` +
            `/caseFlows/${caseFlowId}` +
            `/phases/${phaseId}` +
            `/steps/${stepId}`;

        const response = await executeHttpRequest(approvalDestination, {
            method: "PATCH",
            url,
            headers: {
                "Content-Type": "application/merge-patch+json",
                "If-Match": etag
            },
            data: {
                isSubmittedForApproval: false,
                isApprovalWithdrawn: true,
                withdrawalNote: "Approval withdrawn via API"
            },
            fetchCsrfToken: false
        });
        console.log("Response:", response.data);
    } catch (error) {
        console.error(
            "Approval withdrawal failed:",
            error?.response?.data || error.message
        );
        throw error;
    }
    console.log("Approval withdrawn successfully");
}

async function finishPhaseStep(caseFlowId, phaseId, stepId, etag) {
    // Use phase-level endpoint (not step-level) to complete the phase
    const url =
        `/sap/c4c/api/v1/case-flow-service` +
        `/caseFlows/${caseFlowId}` +
        `/phases/${phaseId}`;

    try {
        const response = await executeHttpRequest(
            destination,
            {
                method: "PATCH",
                url,
                headers: {
                    "Content-Type": "application/merge-patch+json",
                    "If-Match": etag
                },
                data: {
                    status: "COMPLETED_SUCCESS"
                }
            },
            {
                fetchCsrfToken: false
            }
        );

        console.log("Phase finished successfully");
        console.log("Response:", response.data);
    } catch (error) {
        console.error(
            "Finish phase failed:",
            error?.response?.data || error.message
        );
        throw error;
    }
}

/**
 * Set a phase to IN_PROGRESS status (required to unlock/activate a phase)
 */
async function setPhaseInProgress(caseFlowId, phaseId, etag) {
    const url =
        `/sap/c4c/api/v1/case-flow-service` +
        `/caseFlows/${caseFlowId}` +
        `/phases/${phaseId}`;

    try {
        const response = await executeHttpRequest(
            destination,
            {
                method: "PATCH",
                url,
                headers: {
                    "Content-Type": "application/merge-patch+json",
                    "If-Match": etag
                },
                data: {
                    status: "IN_PROGRESS"
                }
            },
            {
                fetchCsrfToken: false
            }
        );

        console.log("Phase set to IN_PROGRESS successfully");
        console.log("Response:", response.data);
    } catch (error) {
        console.error(
            "Set phase IN_PROGRESS failed:",
            error?.response?.data || error.message
        );
        throw error;
    }
}

// ===== Helper functions for postCaseApproval streamlining =====

/**
 * Find existing case for a sales order from extensions or related objects
 * @returns {Promise<{caseId: string|null, caseDisplayId: string|null}>}
 */
async function findCaseForSalesOrder(caseSrv, currentImage) {
    let caseId = currentImage?.extensions?.CaseId_Order;
    let caseDisplayId = null;

    if (caseId) {
        return { caseId, caseDisplayId };
    }

    // Search in related objects
    const salesOrderRelations = currentImage.relatedObjects || [];
    const CASE_OBJECT_TYPE = "2886";

    const existingCaseRelations = salesOrderRelations.filter(rel =>
        rel.type === CASE_OBJECT_TYPE
    );

    for (const rel of existingCaseRelations) {
        try {
            const caseResponse = await caseSrv.send({
                method: "GET",
                path: `/cases/${rel.objectId}?$select=id,caseType,status,displayId`
            });
            const value = caseResponse?.value;
            if (value?.caseType === 'Z12' && value?.status !== '06') {
                return { caseId: value.id, caseDisplayId: value.displayId };
            }
        } catch (e) {
            console.warn("Error fetching case:", rel.objectId, e.message);
        }
    }

    return { caseId: null, caseDisplayId: null };
}

/**
 * Determine business role based on owner's IAM roles
 * @returns {Promise<string>} Business role code ("1822" for Sales Manager, "1824" for Sales Employee)
 */
async function determineBusinessRole(ownerEmployeeId) {
    let businessRole = "1824"; // default Sales Employee

    if (!ownerEmployeeId) {
        return businessRole;
    }

    try {
        const user = await getUserById(ownerEmployeeId);
        const roles = user?.roles || [];
        const isSalesManager = roles.some(role => role?.displayId === "1822");

        if (isSalesManager) {
            businessRole = "1822";
        }
    } catch (e) {
        console.error("User role determination failed:", e?.message || e);
    }

    return businessRole;
}

/**
 * Create a new approval case for a sales order
 * @returns {Promise<{caseId: string, caseDisplayId: string}>}
 */
async function createApprovalCaseForOrder(caseSrv, currentImage) {
    const salesOrderId = currentImage.id;
    const salesOrderDisplayId = currentImage.displayId;
    const account = currentImage.account;
    const individualCustomer = currentImage.individualCustomer;
    const contact = currentImage.primaryContact;
    const ownerPartyId = currentImage?.owner?.id;

    // Build Business Partner Section Dynamically
    let businessPartnerSection = {};
    let contactSection = {};
    let processorSection = {};

    if (account?.id) {
        businessPartnerSection.account = {
            id: account.id,
            displayId: account.displayId
        };

        if (contact?.id) {
            contactSection.contact = {
                id: contact.id,
                displayId: contact.displayId
            };
        }
    } else {
        businessPartnerSection.individualCustomer = {
            id: individualCustomer.id,
            displayId: individualCustomer.displayId
        };
    }

    if (ownerPartyId) {
        processorSection.processor = {
            id: ownerPartyId,
            isMain: true
        };
    }

    const caseBody = {
        subject: `Approval Case for Sales Order ${salesOrderDisplayId}`,
        priority: "03",
        origin: "Z07",
        caseType: "Z12",
        status: "01",
        ...businessPartnerSection,
        ...contactSection,
        ...processorSection,
        relatedObjects: [
            {
                objectId: salesOrderId,
                objectDisplayId: salesOrderDisplayId,
                type: "2059",
                role: "1"
            }
        ]
    };

    console.log("Creating approval case payload:", JSON.stringify(caseBody));

    const createResult = await caseSrv.send({
        method: "POST",
        path: `/cases`,
        headers: { "Content-Type": "application/json" },
        data: caseBody
    });

    const caseId = createResult?.value?.id;
    const caseDisplayId = createResult?.value?.displayId;

    return { caseId, caseDisplayId };
}

/**
 * Determine approval level and approvers from discount matrix
 * @returns {Promise<{approvalLevelCode: string, approvers: Array}>}
 */
async function determineApprovalLevelFromPricing(currentImage, pricing) {
    const DiscountMatrix = 'automotive.discounts.discountMatrix';

    const rawDiscount = pricing.discountPercent;
    const discountPercent = Math.abs(Number(rawDiscount) || 0);

    const salesOrg = currentImage.businessArea.salesOrganisationDisplayId;
    const distributionChannel = currentImage.businessArea.distributionChannel;
    const division = currentImage.businessArea.division;
    const salesOffice = currentImage.businessArea.salesOfficeDisplayId;

    const sellingPriceValue = pricing.sellingPrice ?? 0;
    const costPriceValue = pricing.costPrice ?? 0;
    const isBelowCost = sellingPriceValue < costPriceValue;

    let approverRules = [];
    let approvers = [];

    if (discountPercent === 0) {
        return { approvalLevelCode: '00', approvers: [] };
    }

    if (isBelowCost) {
        approverRules = await SELECT.from(DiscountMatrix)
            .where({ salesOrg, distributionChannel, division, salesOffice, active: true })
            .orderBy("minPercentage asc");
    } else {
        approverRules = await SELECT.from(DiscountMatrix)
            .where({ salesOrg, distributionChannel, division, salesOffice, active: true })
            .and("minPercentage <=", discountPercent)
            .orderBy("minPercentage asc");
    }

    if (!approverRules.length) {
        return { approvalLevelCode: '00', approvers: [] };
    }

    approvers = approverRules.map(rule => ({
        partyId: rule.approverEmployeeId,
        role: rule.approverPartyRole,
        isMain: true
    }));

    const level = Math.min(approvers.length, 5);
    const approvalLevelCode = String(level).padStart(2, '0');

    return { approvalLevelCode, approvers };
}

/**
 * Update case and order extensions with approval level and business role
 */
async function updateApprovalExtensions(caseSrv, caseId, salesOrderId, approvalLevelCode, businessRole, pricing, VSSExternalID) {
    if (caseId) {
        // Validate pricing before patching
        if (!pricing || pricing.sellingPrice == null || pricing.costPrice == null || pricing.discountPercent == null) {
            console.warn("Pricing incomplete. Skipping extension PATCH. Values:", JSON.stringify(pricing));
            return;
        }
    }
    // Update Case extensions
    const { etag: caseEtag } = await getCaseEtag(caseSrv, caseId);

    const casePatchPayload = {
        id: caseId,
        extensions: {
            Approval_Level_Case: approvalLevelCode,
            BusinessRole_Case: businessRole,
            VSSExternalID: VSSExternalID
        }
    };

    console.log("Case Extension PATCH payload:", JSON.stringify(casePatchPayload));
    await patchCaseExtensions(caseSrv, caseId, caseEtag, casePatchPayload);

    // Update Sales Order extensions
    const { etag: orderEtag } = await getOrderEtag(salesOrderId);

    const orderPatchPayload = {
        id: salesOrderId,
        extensions: {
            //       Approval_Level_Order: approvalLevelCode,
            CaseId_Order: caseId
        }
    };

    console.log("Sales Order Extension PATCH payload:", JSON.stringify(orderPatchPayload));
    await patchOrderExtensions(salesOrderId, orderEtag, orderPatchPayload);
    // Trigger SSE push event
    await triggerSSEEvent('SalesOrder', salesOrderId);
}

/**
 * Assign approvers to case as custom employees
 */
async function assignApproversToCase(caseSrv, caseId, approvers) {
    if (!approvers || approvers.length === 0) {
        return;
    }

    const sscv2EmployeeSrv = await cds.connect.to('Sscv2EmployeeService');
    const newCustomEmployees = [];

    for (const approver of approvers) {
        if (approver.partyId) {
            try {
                const employee = await sscv2EmployeeSrv.getEmployeeByDisplayId(approver.partyId);

                if (employee) {
                    newCustomEmployees.push({
                        partyId: employee.employeeId,
                        partyRole: approver.role,
                        isMain: true
                    });
                }
            } catch (e) {
                console.error("Failed to fetch employee:", approver.partyId, e.message);
            }
        }
    }

    if (newCustomEmployees.length === 0) {
        return;
    }

    const { etag, payload: casePayload } = await getCaseEtagWithRetry(caseSrv, caseId);

    if (!etag) {
        console.warn("Could not get case etag for approver assignment, skipping");
        return;
    }

    const existingCustomEmployees = casePayload?.customEmployees || [];
    const mergedEmployees = mergeCustomEmployees(existingCustomEmployees, newCustomEmployees);

    console.log("Assigning approvers PATCH payload:", JSON.stringify(mergedEmployees));
    await patchCasePartyWithRetry(caseSrv, caseId, mergedEmployees, etag);
}
async function patchCasePartyWithRetry(caseSrv, caseId, mergedEmployees, etag) {
    const maxRetries = 3;
    for (let attempt = 1; attempt <= maxRetries; attempt++) {

        try {

            // Always get the latest ETag with retry
            //const { etag, payload: currentCase } = await getCaseEtagWithRetry(caseSrv, caseId);

            if (!etag) {
                console.warn(`patchCasePartyWithRetry: Could not get etag on attempt ${attempt}, skipping patch`);
                return; // Return without throwing to allow process to continue
            }

            console.log(`PATCH attempt ${attempt}, ETag: ${etag}`);

            return await patchCaseParty(
                caseSrv,
                caseId,
                etag,
                mergedEmployees
            );

        } catch (err) {

            const message =
                err.response?.data?.error?.message ||
                err.message;

            console.warn(`PATCH failed (attempt ${attempt}): ${message}`);

            // Retry for optimistic locking conflict or transient errors
            if (attempt < maxRetries) {
                // Wait 500ms before retrying
                await new Promise(resolve => setTimeout(resolve, 500));
                continue;
            }

            // All retries exhausted - log error but don't throw to allow process to continue
            console.error(`patchCasePartyWithRetry failed after ${maxRetries} attempts. Continuing with approval process.`);
            return; // Return without throwing
        }
    }
}
class salesorderExthook extends cds.ApplicationService {
    init() {

        this.on('preCaseApproval', async (req) => {
            console.log("createCaseAutoflow triggered");
            const { data } = req.data;
            const DiscountMatrix = 'automotive.discounts.discountMatrix';
            const currentImage = data.currentImage;
            const beforeImage = data.beforeImage;
            let caseId;
            let caseDisplayId;
            // console.log("Incoming SO Payload:", JSON.stringify(req.data));
            // Connect to Case Service using CDS external service
            const caseSrv = await cds.connect.to('Case.Service');

            try {
                if (!currentImage) {
                    return req.error(400, "Missing Sales Order payload");
                }

                // Extract Required Fields
                const salesOrderId = currentImage.id;
                const salesOrderDisplayId = currentImage.displayId;
                const account = currentImage.account;
                const individualCustomer = currentImage.individualCustomer;
                const contact = currentImage.primaryContact;
                const netAmount = currentImage.totalValues?.netAmount?.content;
                const currency = currentImage.totalValues?.netAmount?.currencyCode;
                const ownerPartyId = currentImage?.owner?.id;
                console.log("Sales Order ownerPartyId:", ownerPartyId);
                console.log("case submit approval CaseId_Order for this Sales Order:", currentImage?.extensions?.CaseId_Order);
                caseId = currentImage?.extensions?.CaseId_Order;

                if (!salesOrderId) {
                    return req.error(400, "Missing Sales Order ID");
                }

                if (!account?.id && !individualCustomer?.id) {
                    return req.error(400, "Either Account or Individual Customer must exist");
                }
                if (!caseId) {
                    const salesOrderRelations = currentImage.relatedObjects || [];

                    // Case object type (confirm in tenant)
                    const CASE_OBJECT_TYPE = "2886";

                    const existingCaseRelation = salesOrderRelations.filter(rel =>
                        rel.type === CASE_OBJECT_TYPE
                    );

                    for (const rel of existingCaseRelation) {
                        const caseResponse = await caseSrv.send({
                            method: "GET",
                            path: `/cases/${rel.objectId}?$select=id,caseType,status,displayId`
                        });
                        const value = caseResponse?.value;
                        if (value?.caseType === 'Z12' && value?.status != '06') {
                            console.log("Case Type exists for this Sales Order:", value?.caseType);
                            caseId = value.id;
                            caseDisplayId = value.displayId;
                            break;
                        }
                    }
                }
                if (caseId) {
                    console.log("Case already exists for this Sales Order:", caseId, caseDisplayId);
                }
                else {
                    // Create Approval Case 
                    // Build Business Partner Section Dynamically
                    let businessPartnerSection = {};
                    let contactSection = {};
                    let processorSection = {};
                    if (account?.id) {
                        businessPartnerSection.account = {
                            id: account.id,
                            displayId: account.displayId
                        };

                        // Add contact ONLY when account exists
                        if (contact?.id) {
                            contactSection.contact = {
                                id: contact.id,
                                displayId: contact.displayId
                            };
                        }
                    } else {
                        businessPartnerSection.individualCustomer = {
                            id: individualCustomer.id,
                            displayId: individualCustomer.displayId
                        };
                        // DO NOT add contact when individual customer
                    }


                    // owner of SO
                    if (ownerPartyId) {
                        processorSection.processor = {
                            id: ownerPartyId,
                            isMain: true
                        };
                    }

                    // console.log("Calling external Case API businessPartnerSection" + JSON.stringify(businessPartnerSection));
                    //console.log("Calling external Case API processorSection" + JSON.stringify(processorSection.processor));

                    // Build Body for Approval Case Service
                    const caseBody = {
                        subject: `Approval Case for Sales Order ${salesOrderDisplayId}`,
                        priority: "03",
                        origin: "Z07",
                        caseType: "Z12",
                        status: "01",
                        ...businessPartnerSection,
                        ...contactSection,
                        ...processorSection,
                        // Link Sales Order as Related Object
                        relatedObjects: [
                            {
                                objectId: salesOrderId,
                                "objectDisplayId": salesOrderDisplayId,
                                "type": "2059",
                                "role": "1"
                            }
                        ]
                    };

                    console.log("Calling external Case API..." + JSON.stringify(caseBody));

                    // Create Case using POST via CDS service
                    const createResult = await caseSrv.send({
                        method: "POST",
                        path: `/cases`,
                        headers: {
                            "Content-Type": "application/json"
                        },
                        data: caseBody
                    });

                    //console.log("Approval Case created successfully:", createResult);

                    caseId = createResult?.value?.id;
                    caseDisplayId = createResult?.value?.displayId;

                    console.log("Case ID:", caseId);
                    console.log("Case Display ID:", caseDisplayId);

                }


                // determine the approval level for Case
                // Fetch complete Sales Order via API to get priceElements (webhook payload doesn't include them)
                let { etag: orderEtagForPricing, payload: fullOrderPayload } = await getOrderEtag(salesOrderId);
                console.log("Fetched full Sales Order payload with priceElements");

                // Extract pricing from API response (which includes priceElements)
                const pricing = extractHeaderPricing(fullOrderPayload || {});
                console.log("1. Extracted Header Pricing:", pricing);

                // Use fullOrderPayload for pricing comparison (webhook payload doesn't include priceElements)
                const pricingChanged = isRelevantPricingChanged(
                    beforeImage || {},
                    fullOrderPayload || {}
                );
                console.log("2.Sales Order is pricingChanged:", pricingChanged);

                // determine approvers from discount matrix
                const rawDiscount = pricing.discountPercent;
                // Always use positive discount for approval logic
                const discountPercent = Math.abs(Number(rawDiscount) || 0);

                console.log(`3.Discount normalization: raw=${rawDiscount}, normalized=${discountPercent}`);

                const salesOrg = currentImage.businessArea.salesOrganisationDisplayId;
                const distributionChannel = currentImage.businessArea.distributionChannel;
                const division = currentImage.businessArea.division;
                const salesOffice = currentImage.businessArea.salesOfficeDisplayId;

                const sellingPriceValue = pricing.sellingPrice ?? 0;
                const costPriceValue = pricing.costPrice ?? 0;
                const isBelowCost = sellingPriceValue < costPriceValue;

                console.log(
                    "Price comparison → Selling:", sellingPriceValue,
                    "Cost:", costPriceValue,
                    "Below cost?", isBelowCost
                );

                let approvalLevelCode = '00';
                let approverRules = [];
                let approvers = [];
                console.log("4.Approval matrix Extracted Header discount:", discountPercent);

                if (discountPercent === 0) {
                    approvalLevelCode = '00';
                }
                else if (isBelowCost) {
                    // OVERRIDE CASE → Selling < Cost
                    console.log("4.Selling price below cost → forcing all approval levels");

                    approverRules = await SELECT.from(DiscountMatrix)
                        .where({
                            salesOrg,
                            distributionChannel,
                            division,
                            salesOffice,
                            active: true
                        })
                        .orderBy("minPercentage asc");


                } else {
                    // NORMAL DISCOUNT-BASED FLOW
                    approverRules = await SELECT.from(DiscountMatrix)
                        .where({
                            salesOrg,
                            distributionChannel,
                            division,
                            salesOffice,
                            active: true
                        })
                        .and("minPercentage <=", discountPercent)
                        .orderBy("minPercentage asc");

                    if (!approverRules.length) {
                        console.log("5.Sales Order No approver found from Discount Matrix");
                    }
                }

                if (discountPercent > 0) {
                    // No approval required
                    if (!approverRules.length) {
                        console.log("5.Sales Order No approver found from Discount Matrix");
                        approvalLevelCode = '00';
                    } else {
                        // Build approver list
                        approvers = approverRules.map(rule => ({
                            partyId: rule.approverEmployeeId,
                            role: rule.approverPartyRole,
                            isMain: true
                        }));

                        // Derive approval level code from approvers
                        const approverCount = approvers?.length;
                        const level = Math.min(approverCount, 5);

                        // Convert to 2-digit code: 1 → "01"
                        approvalLevelCode =
                            level > 0 ? String(level).padStart(2, '0') : null;
                    }
                }

                let { etag: caseEtag, payload: caseImage } = await getCaseEtag(caseSrv, caseId);

                console.log("Case current caseEtag ", caseEtag);

                const currentLevel = caseImage?.extensions?.Approval_Level_Case;
                console.log("6.Case approver currentLevel " + currentLevel);
                console.log("6.Case approver derived approvalLevelCode " + approvalLevelCode);
                const caseId_Order = currentImage?.extensions?.CaseId_Order;;
                console.log("6.Case approver caseId_Order " + caseId_Order);

                if (pricingChanged || currentLevel !== approvalLevelCode || caseId_Order) {
                    // Validate pricing fields before patching
                    if (
                        pricing == null ||
                        pricing.sellingPrice == null ||
                        pricing.costPrice == null ||
                        pricing.discountPercent == null
                    ) {
                        console.warn(
                            "Pricing incomplete. Skipping PATCH. Values:",
                            JSON.stringify(pricing)
                        );
                    }

                    // Determine business role based on owner's IAM roles
                    let businessRole = "1824"; // default Sales Employee

                    try {
                        const ownerEmployeeId = currentImage?.owner?.partyId;
                        console.log("preCaseApproval ownerEmployeeId:", ownerEmployeeId);

                        if (ownerEmployeeId) {
                            const user = await getUserById(ownerEmployeeId);
                            console.log("IAM User:", JSON.stringify(user));

                            const roles = user?.roles || [];
                            console.log("IAM Roles:", JSON.stringify(roles));

                            const isSalesManager = roles.some(role =>
                                role?.displayId === "1822"
                            );

                            if (isSalesManager) {
                                businessRole = "1822";
                                console.log("Sales Manager detected");
                            } else {
                                console.log("Sales Employee detected");
                            }
                        }
                    } catch (e) {
                        console.error("User role determination failed:", e?.message || e);
                    }

                    // Build CasePATCH payload for approval level and business role
                    const patchPayload = {
                        id: caseId,
                        extensions: {
                            Approval_Level_Case: approvalLevelCode,
                            BusinessRole_Case: businessRole
                        }
                    };

                    console.log("Case Extension Patch Payload:", JSON.stringify(patchPayload));

                    // Execute PATCH Approval level and business role
                    await patchCaseExtensions(
                        caseSrv,
                        caseId,
                        caseEtag,
                        patchPayload
                    );

                    console.log("8.case price extension fields approval level and business role updated successfully");
                    //Sales order extension fields update
                    // Get order etag for patching
                    let { etag: orderEtag, payload: orderImage } = await getOrderEtag(salesOrderId);

                    // Build PATCH payload for sales order case id and approval level
                    const SOPayload = {
                        id: salesOrderId,
                        extensions: {
                            //                       Approval_Level_Order: approvalLevelCode,
                            CaseId_Order: caseId
                        }
                    };

                    console.log("sales order Extension Patch Payload:", JSON.stringify(SOPayload));

                    // Execute PATCH Approval level
                    await patchOrderExtensions(
                        salesOrderId,
                        orderEtag,
                        SOPayload
                    );

                     // Trigger SSE push event
                    await triggerSSEEvent('SalesOrder', salesOrderId);
                    console.log("8. Sales Order extension fields approval level updated successfully");
                }

                // --------------------------------------------------
                //  Assign approvers to Case (V2 API)
                // --------------------------------------------------
                const sscv2EmployeeSrv = await cds.connect.to('Sscv2EmployeeService');
                const newCustomEmployees = [];
                for (const approver of approvers) {
                    console.log("9.Case approver info found from Discount Matrix " + approver.role, approver.partyId);

                    // Fetch Employee UUID from Sales Cloud V2
                    let approverEmployeeUUID;
                    if (approver.partyId) {
                        try {
                            const employee = await sscv2EmployeeSrv.getEmployeeByDisplayId(approver.partyId);
                            console.log("Case Autoflow Approver employee " + employee.employeeId);
                            if (!employee) {
                                req.error(
                                    400,
                                    `No employee found in Sales Cloud for employeeId ${approver.partyId}`
                                );
                            }

                            newCustomEmployees.push({
                                partyId: employee.employeeId,   // UUID
                                partyRole: approver.role,
                                isMain: true
                            });
                        } catch (e) {
                            req.error(400, e.message);
                        }
                    }
                }

                // Latest case etag with retry
                const { etag, payload: casePayload } = await getCaseEtagWithRetry(caseSrv, caseId);

                const existingCustomEmployees = casePayload?.customEmployees || [];

                console.log("existingCustomEmployees Body:", JSON.stringify(existingCustomEmployees));

                const mergedEmployees = mergeCustomEmployees(
                    existingCustomEmployees,
                    newCustomEmployees
                );

                // Execute customEmployees patch with automatic retry (function handles errors internally and won't throw)
                console.log("Starting patchCasePartyWithRetry for caseId with etag mergedEmployees:", caseId, etag, mergedEmployees);
                await patchCasePartyWithRetry(
                    caseSrv,
                    caseId,
                    mergedEmployees,
                    etag
                );
                console.log("patchCasePartyWithRetry completed , continuing with approval process");

                // Set the case to submit for PRE/POST approval via API based on PRE/POST conditions
                if (caseId) {
                    console.log("Set the case to submit for approval via API");

                    // Get both PRE and POST approval contexts
                    const preContext = await getApprovalStepContext(caseId, 'PRE');
                    const postContext = await getApprovalStepContext(caseId, 'POST');

                    console.log("PRE context:", preContext?.status, "isSubmitted:", preContext?.isSubmittedForApproval, "isWithdrawn:", preContext?.isApprovalWithdrawn);
                    console.log("POST context:", postContext?.status, "isSubmitted:", postContext?.isSubmittedForApproval, "isWithdrawn:", postContext?.isApprovalWithdrawn);

                    // Check if PRE is completed
                    if (preContext?.status === 'COMPLETED_SUCCESS') {
                        // PRE is completed, submit POST if not already submitted
                        console.log("PRE is completed, checking POST approval for submission");
                        if (postContext && !postContext.isSubmittedForApproval) {
                            console.log("Submit POST-VSS approval via API");
                            const { etag } = await getCaseEtagWithRetry(caseSrv, caseId);
                            if (etag) {
                                await submitCaseApproval(
                                    caseId,
                                    postContext.caseFlowId,
                                    postContext.phaseId,
                                    postContext.stepId,
                                    etag
                                );
                            } else {
                                console.warn("Could not get case etag for POST approval submission, skipping");
                            }
                        } else if (postContext?.isSubmittedForApproval &&
                            !postContext?.isApprovalWithdrawn &&
                            postContext?.status === "IN_PROGRESS") {
                            console.log("POST approval already submitted → skip");
                        } else {
                            console.warn("No POST approval step found for case");
                        }
                    } else {
                        // PRE is NOT completed, submit PRE if not already submitted
                        console.log("PRE is not completed, checking PRE approval for submission");
                        if (preContext && !preContext.isSubmittedForApproval) {
                            console.log("Submit PRE-VSS approval via API");
                            const { etag } = await getCaseEtagWithRetry(caseSrv, caseId);
                            if (etag) {
                                await submitCaseApproval(
                                    caseId,
                                    preContext.caseFlowId,
                                    preContext.phaseId,
                                    preContext.stepId,
                                    etag
                                );
                            } else {
                                console.warn("Could not get case etag for PRE approval submission, skipping");
                            }
                        } else if (preContext?.isSubmittedForApproval &&
                            !preContext?.isApprovalWithdrawn &&
                            preContext?.status === "IN_PROGRESS") {
                            console.log("PRE approval already submitted → skip");
                        } else {
                            console.warn("No PRE approval step found for case");
                        }
                    }
                }
               
                return { status: "success" };

            } catch (error) {
                console.error("Case approval processing failed:", error?.response?.data || error.message);
                return req.error(500, "Case approval processing failed");
            }
        });


        this.on('withdrawApproval', async (req) => {
            console.log("withdrawApproval triggered");
            const { data } = req.data;
            const DiscountMatrix = 'automotive.discounts.discountMatrix';
            const currentImage = data.currentImage;
            const beforeImage = data.beforeImage;
            let caseId;
            let caseDisplayId;

            //console.log("Incoming SO Payload:", JSON.stringify(req.data));
            // Connect to Case Service using CDS external service
            const caseSrv = await cds.connect.to('Case.Service');

            try {
                if (!currentImage) {
                    return req.error(400, "Missing Sales Order payload");
                }

                // Extract Required Fields
                const salesOrderId = currentImage.id;
                const salesOrderDisplayId = currentImage.displayId;
                const account = currentImage.account;
                const individualCustomer = currentImage.individualCustomer;
                const contact = currentImage.primaryContact;
                const netAmount = currentImage.totalValues?.netAmount?.content;
                const currency = currentImage.totalValues?.netAmount?.currencyCode;
                console.log("withdraw approval CaseId_Order for this Sales Order:", currentImage?.extensions?.CaseId_Order);
                caseId = currentImage?.extensions?.CaseId_Order;
                if (!salesOrderId) {
                    return req.error(400, "Missing Sales Order ID");
                }

                if (!account?.id && !individualCustomer?.id) {
                    return req.error(400, "Either Account or Individual Customer must exist");
                }

                if (!caseId) {
                    const salesOrderRelations = currentImage.relatedObjects || [];

                    // Case object type (confirm in tenant)
                    const CASE_OBJECT_TYPE = "2886";

                    const existingCaseRelation = salesOrderRelations.filter(rel =>
                        rel.type === CASE_OBJECT_TYPE
                    );

                    for (const rel of existingCaseRelation) {
                        const caseResponse = await caseSrv.send({
                            method: "GET",
                            path: `/cases/${rel.objectId}?$select=id,caseType,status,displayId`
                        });
                        const value = caseResponse?.value;
                        if (value?.caseType === 'Z12' && value?.status != '06') {
                            console.log("Case Type exists for this Sales Order:", value?.caseType);
                            caseId = value.id;
                            caseDisplayId = value.displayId;
                            break;
                        }
                    }
                }
                if (!caseId) {
                    console.log("No Case exists for this Sales Order:");
                    return { status: "No Case exists for this Sales Order" };
                }
                console.log("withdraw approval Case already exists for this Sales Order:", caseId);
                // Set the case to withdraw approval via API based on PRE/POST conditions
                if (caseId) {

                    const newLineAdded = hasNewLineAdded(beforeImage, currentImage);
                    const discountChanged = isDiscountChanged(beforeImage, currentImage);
                    console.log("newLineAdded for this Sales Order:" + newLineAdded);
                    console.log("discountChanged for this Sales Order:" + discountChanged);

                    // if (newLineAdded || discountChanged) {
                    //   console.log("Approval must be withdrawn due to changes");

                    // Get both PRE and POST approval contexts
                    const preContext = await getApprovalStepContext(caseId, 'PRE');
                    const postContext = await getApprovalStepContext(caseId, 'POST');

                    console.log("PRE context:", preContext?.status, "isSubmitted:", preContext?.isSubmittedForApproval, "isWithdrawn:", preContext?.isApprovalWithdrawn);
                    console.log("POST context:", postContext?.status, "isSubmitted:", postContext?.isSubmittedForApproval, "isWithdrawn:", postContext?.isApprovalWithdrawn);

                    // Check if PRE is completed
                    if (preContext?.status === 'COMPLETED_SUCCESS') {
                        // PRE is completed, withdraw POST if submitted
                        console.log("PRE is completed, checking POST approval for withdrawal");
                        if (postContext && postContext.isSubmittedForApproval &&
                            !postContext.isApprovalWithdrawn) {
                            console.log("Withdraw POST-VSS approval via API");
                            await withdrawCaseApproval(
                                caseId,
                                postContext.caseFlowId,
                                postContext.phaseId,
                                postContext.stepId,
                                postContext.etag
                            );
                        } else {
                            console.log("POST-VSS approval not submitted or already withdrawn → skip");
                        }
                    } else {
                        // PRE is NOT completed, withdraw PRE if submitted
                        console.log("PRE is not completed, checking PRE approval for withdrawal");
                        if (preContext && preContext.isSubmittedForApproval &&
                            !preContext.isApprovalWithdrawn) {
                            console.log("Withdraw PRE-VSS approval via API");
                            await withdrawCaseApproval(
                                caseId,
                                preContext.caseFlowId,
                                preContext.phaseId,
                                preContext.stepId,
                                preContext.etag
                            );
                        } else {
                            console.log("PRE-VSS approval not submitted or already withdrawn → skip");
                        }
                    }
                    //  }
                }
                return { status: "success" };

            } catch (error) {
                console.error("Case withdraw approval processing failed:", error?.response?.data || error.message);
                return req.error(500, "Case withdraw approval processing failed");
            }
        });

        // Combined action: First withdraw approval (if needed), then create/update case autoflow
        this.on('postCaseApproval', async (req) => {
            console.log("postCaseApproval triggered");
            const { data } = req.data;
            const currentImage = data.currentImage;
            const beforeImage = data.beforeImage;

            const caseSrv = await cds.connect.to('Case.Service');

            try {
                // ===== VALIDATION =====
                if (!currentImage) {
                    return req.error(400, "Missing Sales Order payload");
                }

                const salesOrderId = currentImage.id;
                const account = currentImage.account;
                const individualCustomer = currentImage.individualCustomer;
                const VSSExternalID = currentImage.externalId?.displayId; //VSS ID
                console.log("Post Approval VSSExternalID:", VSSExternalID);

                if (!salesOrderId) {
                    return req.error(400, "Missing Sales Order ID");
                }

                if (!account?.id && !individualCustomer?.id) {
                    return req.error(400, "Either Account or Individual Customer must exist");
                }

                // ===== STEP 0: Find existing Case using helper =====
                let { caseId, caseDisplayId } = await findCaseForSalesOrder(caseSrv, currentImage);

                // ===== STEP 0: Create Case if not exists (using helper functions) =====
                if (!caseId) {
                    const result = await createApprovalCaseForOrder(caseSrv, currentImage);
                    caseId = result.caseId;
                    caseDisplayId = result.caseDisplayId;
                }

                if (caseId) {
                    // For newly created case, determine approval level and update extensions
                    const { payload: fullOrderPayload } = await getOrderEtag(salesOrderId);
                    const pricing = extractHeaderPricing(fullOrderPayload || {});

                    const { approvalLevelCode, approvers } = await determineApprovalLevelFromPricing(currentImage, pricing);
                    const businessRole = await determineBusinessRole(currentImage?.owner?.partyId);

                    await updateApprovalExtensions(caseSrv, caseId, salesOrderId, approvalLevelCode, businessRole, pricing, VSSExternalID);
                    await assignApproversToCase(caseSrv, caseId, approvers);


                    // ===== STEP 5: Finish PRE Approval (required before POST approval can proceed) =====

                    const preApprovalContext = await getApprovalStepContext(caseId, 'PRE');

                    if (preApprovalContext) {
                        if (preApprovalContext.status !== 'COMPLETED_SUCCESS') {
                            // Complete the PRE phase
                            await finishPhaseStep(
                                preApprovalContext.caseFlowId,
                                preApprovalContext.phaseId,
                                preApprovalContext.stepId,
                                preApprovalContext.etag
                            );

                            // After completing PRE phase, set POST phase to IN_PROGRESS to unlock it
                            const postApprovalContext = await getApprovalStepContext(caseId, 'POST');
                            if (postApprovalContext && postApprovalContext.status !== 'IN_PROGRESS' && postApprovalContext.status !== 'COMPLETED_SUCCESS') {
                                console.log("Setting POST phase to IN_PROGRESS to unlock it");
                                await setPhaseInProgress(
                                    postApprovalContext.caseFlowId,
                                    postApprovalContext.phaseId,
                                    postApprovalContext.etag
                                );
                            }
                        }
                    } else {
                        console.warn("No PRE approval step found for case");
                    }
                }

                // ===== STEP 1: Withdraw POST-VSS Approval (if discount changed or new line added) =====
                if (caseId) {
                    const newLineAdded = hasNewLineAdded(beforeImage, currentImage);
                    const discountChanged = isDiscountChanged(beforeImage, currentImage);

                    // If discount changed, update business role
                    if (discountChanged) {
                        const businessRole = await determineBusinessRole(currentImage?.owner?.partyId);

                        try {
                            const { etag: caseEtag } = await getCaseEtagWithRetry(caseSrv, caseId);

                            if (caseEtag) {
                                const patchPayload = {
                                    id: caseId,
                                    extensions: { BusinessRole_Case: businessRole }
                                };
                                console.log("BusinessRole_Case PATCH payload:", JSON.stringify(patchPayload));
                                await patchCaseExtensions(caseSrv, caseId, caseEtag, patchPayload);
                            } else {
                                console.warn("Could not get case etag for BusinessRole_Case update, skipping");
                            }
                        } catch (e) {
                            console.error("Failed to update BusinessRole_Case:", e?.message || e);
                        }
                    }

                    const postApprovalContext = await getApprovalStepContext(caseId, 'POST');

                    if (postApprovalContext) {
                        // Withdraw if needed
                        if (postApprovalContext.isSubmittedForApproval &&
                            !postApprovalContext.isApprovalWithdrawn &&
                            (newLineAdded || discountChanged)) {
                            await withdrawCaseApproval(
                                caseId,
                                postApprovalContext.caseFlowId,
                                postApprovalContext.phaseId,
                                postApprovalContext.stepId,
                                postApprovalContext.etag
                            );
                        }
                    } else {
                        console.warn("No POST approval step found for case");
                    }
                }

                // ===== STEP 2: Submit for POST-VSS Approval =====
                if (caseId) {
                    const postApprovalContext = await getApprovalStepContext(caseId, 'POST');

                    if (!postApprovalContext) {
                        console.warn("No POST approval step found for case");
                    } else {
                        // Submit if not already submitted
                        const alreadySubmitted = postApprovalContext.isSubmittedForApproval &&
                            !postApprovalContext.isApprovalWithdrawn &&
                            postApprovalContext.status === "IN_PROGRESS";

                        if (!alreadySubmitted) {
                            const { etag } = await getCaseEtagWithRetry(caseSrv, caseId);
                            if (etag) {
                                await submitCaseApproval(
                                    caseId,
                                    postApprovalContext.caseFlowId,
                                    postApprovalContext.phaseId,
                                    postApprovalContext.stepId,
                                    etag
                                );
                            } else {
                                console.warn("Could not get case etag for POST approval submission, skipping");
                            }
                        }
                    }
                }
               
                return { status: "success" };

            } catch (error) {
                console.error("postCaseApproval processing failed:", error?.response?.data || error.message);
                return req.error(500, "postCaseApproval processing failed");
            }
        });

        // Finish PRE-VSS Approval phase step
        this.on('finishPreApproval', async (req) => {
            console.log("finishPreApproval triggered");
            const { data } = req.data;
            const currentImage = data.currentImage;
            let caseId;

            console.log("Incoming SO Payload:", JSON.stringify(req.data));
            // Connect to Case Service using CDS external service
            const caseSrv = await cds.connect.to('Case.Service');

            try {
                if (!currentImage) {
                    return req.error(400, "Missing Sales Order payload");
                }

                // Extract caseId from extensions or related objects
                console.log("finishPreApproval CaseId_Order for this Sales Order:", currentImage?.extensions?.CaseId_Order);
                caseId = currentImage?.extensions?.CaseId_Order;

                if (!caseId) {
                    const salesOrderRelations = currentImage.relatedObjects || [];
                    const CASE_OBJECT_TYPE = "2886";

                    const existingCaseRelation = salesOrderRelations.filter(rel =>
                        rel.type === CASE_OBJECT_TYPE
                    );

                    for (const rel of existingCaseRelation) {
                        const caseResponse = await caseSrv.send({
                            method: "GET",
                            path: `/cases/${rel.objectId}?$select=id,caseType,status,displayId`
                        });
                        const value = caseResponse?.value;
                        if (value?.caseType === 'Z12' && value?.status != '06') {
                            console.log("Case Type exists for this Sales Order:", value?.caseType);
                            caseId = value.id;
                            break;
                        }
                    }
                }

                if (!caseId) {
                    console.log("No Case exists for this Sales Order");
                    return { status: "No Case exists for this Sales Order" };
                }

                console.log("finishPreApproval Case found:", caseId);

                // Get PRE approval step context
                const preApprovalContext = await getApprovalStepContext(caseId, 'PRE');

                if (!preApprovalContext) {
                    console.warn("No PRE approval step found for case");
                    return { status: "No PRE approval step found" };
                }

                console.log("PRE approval context:", preApprovalContext.status);

                // Finish the PRE phase step
                console.log("Finishing PRE-VSS approval phase step");
                await finishPhaseStep(
                    preApprovalContext.caseFlowId,
                    preApprovalContext.phaseId,
                    preApprovalContext.stepId,
                    preApprovalContext.etag
                );

                return { status: "success" };

            } catch (error) {
                console.error("finishPreApproval processing failed:", error?.response?.data || error.message);
                return req.error(500, "finishPreApproval processing failed");
            }
        });

        // Finish POST-VSS Approval phase step
        this.on('finishPostApproval', async (req) => {
            console.log("finishPostApproval triggered");
            const { data } = req.data;
            const currentImage = data.currentImage;
            let caseId;

            console.log("Incoming SO Payload:", JSON.stringify(req.data));
            // Connect to Case Service using CDS external service
            const caseSrv = await cds.connect.to('Case.Service');

            try {
                if (!currentImage) {
                    return req.error(400, "Missing Sales Order payload");
                }

                // Extract caseId from extensions or related objects
                console.log("finishPostApproval CaseId_Order for this Sales Order:", currentImage?.extensions?.CaseId_Order);
                caseId = currentImage?.extensions?.CaseId_Order;

                if (!caseId) {
                    const salesOrderRelations = currentImage.relatedObjects || [];
                    const CASE_OBJECT_TYPE = "2886";

                    const existingCaseRelation = salesOrderRelations.filter(rel =>
                        rel.type === CASE_OBJECT_TYPE
                    );

                    for (const rel of existingCaseRelation) {
                        const caseResponse = await caseSrv.send({
                            method: "GET",
                            path: `/cases/${rel.objectId}?$select=id,caseType,status,displayId`
                        });
                        const value = caseResponse?.value;
                        if (value?.caseType === 'Z12' && value?.status != '06') {
                            console.log("Case Type exists for this Sales Order:", value?.caseType);
                            caseId = value.id;
                            break;
                        }
                    }
                }

                if (!caseId) {
                    console.log("No Case exists for this Sales Order");
                    return { status: "No Case exists for this Sales Order" };
                }

                console.log("finishPostApproval Case found:", caseId);

                // Get POST approval step context
                const postApprovalContext = await getApprovalStepContext(caseId, 'POST');

                if (!postApprovalContext) {
                    console.warn("No POST approval step found for case");
                    return { status: "No POST approval step found" };
                }

                console.log("POST approval context:", postApprovalContext.status);

                // Finish the POST phase step
                console.log("Finishing POST-VSS approval phase step");
                await finishPhaseStep(
                    postApprovalContext.caseFlowId,
                    postApprovalContext.phaseId,
                    postApprovalContext.stepId,
                    postApprovalContext.etag
                );

                return { status: "success" };

            } catch (error) {
                console.error("finishPostApproval processing failed:", error?.response?.data || error.message);
                return req.error(500, "finishPostApproval processing failed");
            }
        });

        // Determine Approval Level - simplified version without case creation/management
        this.on('determineApprovalLevel', async (req) => {
            console.log("determineApprovalLevel triggered");
            const { data } = req.data;
            const DiscountMatrix = 'automotive.discounts.discountMatrix';
            const currentImage = data.currentImage;
            const beforeImage = data.beforeImage;

            // Connect to Sales Quote Service
            const salesQuoteSrv = await cds.connect.to('Sales.Quote.Service');

            try {
                if (!currentImage) {
                    return req.error(400, "Missing Sales Order payload");
                }

                // Extract Required Fields
                const salesOrderId = currentImage.id;
                const salesOrderDisplayId = currentImage.displayId;
                const account = currentImage.account;
                const individualCustomer = currentImage.individualCustomer;

                if (!salesOrderId) {
                    return req.error(400, "Missing Sales Order ID");
                }

                if (!account?.id && !individualCustomer?.id) {
                    return req.error(400, "Either Account or Individual Customer must exist");
                }

                // Determine the approval level
                // Fetch complete Sales Order via API to get priceElements (webhook payload doesn't include them)
                let { etag: orderEtagForPricing, payload: fullOrderPayload } = await getOrderEtag(salesOrderId);
                console.log("Fetched full Sales Order payload with priceElements");

                // Extract pricing from API response (which includes priceElements)
                const pricing = extractHeaderPricing(fullOrderPayload || {});
                console.log("1. Extracted Header Pricing from Order:", pricing);

                // ===== ZTOT Discount Comparison between Quote and Order =====
                // Find the related Sales Quote from relatedObjects
                const QUOTE_OBJECT_TYPE = "30";
                const salesOrderRelations = fullOrderPayload?.relatedObjects || [];
                const quoteRelation = salesOrderRelations.find(rel =>
                    rel.type === QUOTE_OBJECT_TYPE && rel.role === "PREDECESSOR"
                );

                let quoteZtotDiscount = 0;
                let quoteId = null;

                if (quoteRelation?.objectId) {
                    quoteId = quoteRelation.objectId;
                    console.log("Found related Sales Quote:", quoteId, "displayId:", quoteRelation.displayId);

                    try {
                        // Fetch Sales Quote to get ZTOT discount
                        const { etag: quoteEtag, payload: quotePayload } = await getSalesQuoteEtag(salesQuoteSrv, quoteId);
                        console.log("Fetched Sales Quote payload with priceElements");

                        // Extract ZTOT discount from Quote
                        const quotePricing = extractHeaderPricing(quotePayload || {});
                        quoteZtotDiscount = Math.abs(Number(quotePricing.discountPercent) || 0);
                        console.log("2. Extracted Quote ZTOT Discount:", quoteZtotDiscount);
                    } catch (quoteError) {
                        console.warn("Could not fetch Sales Quote, proceeding without quote comparison:", quoteError.message);
                    }
                } else {
                    console.log("No related Sales Quote found for this Sales Order");
                }

                // Get Order ZTOT discount
                const orderZtotDiscount = Math.abs(Number(pricing.discountPercent) || 0);
                console.log("3. Order ZTOT Discount:", orderZtotDiscount);
                console.log("3. Quote ZTOT Discount:", quoteZtotDiscount);

                // Compare ZTOT discount between Quote and Order
                const ztotChanged = orderZtotDiscount !== quoteZtotDiscount;
                console.log("4. ZTOT Discount Changed (Quote vs Order):", ztotChanged);
                const newLineAdded = hasNewLineAdded(beforeImage, currentImage);
                const discountChanged = isDiscountChanged(beforeImage, currentImage);
                console.log("newLineAdded for this Sales Order:" + newLineAdded);
                console.log("discountChanged for this Sales Order:" + discountChanged);

                // If ZTOT discount has not changed, update extension approval level code to '00'
                if (!ztotChanged && !newLineAdded && !discountChanged) {
                    console.log("ZTOT discount has not changed between Quote and Order");

                    // Get current approval level from Sales Order
                    const currentApprovalLevel = fullOrderPayload?.extensions?.Approval_Level_Order;
                    console.log("Current Approval_Level_Order:", currentApprovalLevel);

                    // Only update if current approval level is not already '00'
                    if (currentApprovalLevel !== '00') {
                        console.log("Current approval level is not '00', updating to '00'");

                        // Get order etag for patching
                        let { etag: orderEtag, payload: orderImage } = await getOrderEtag(salesOrderId);

                        // Build PATCH payload for sales order approval level
                        const SOPayload = {
                            id: salesOrderId,
                            extensions: {
                                Approval_Level_Order: '00'
                            }
                        };

                        console.log("Sales Order Extension Patch Payload:", JSON.stringify(SOPayload));

                        // Execute PATCH Approval level
                        await patchOrderExtensions(
                            salesOrderId,
                            orderEtag,
                            SOPayload
                        );

                        console.log("Sales Order extension field Approval_Level_Order updated to '00' (ZTOT unchanged)");
                    } else {
                        console.log("Current approval level is already '00', skipping update");
                    }

                    return {
                        status: "success",
                        approvalLevelCode: '00',
                        discountPercent: orderZtotDiscount,
                        quoteDiscountPercent: quoteZtotDiscount,
                        isBelowCost: false,
                        approverCount: 0,
                        message: "ZTOT discount unchanged between Quote and Order, approval level set to '00'"
                    };
                }

                // Determine approvers from discount matrix
                const rawDiscount = pricing.discountPercent;
                // Always use positive discount for approval logic
                const discountPercent = Math.abs(Number(rawDiscount) || 0);

                console.log(`3.Discount normalization: raw=${rawDiscount}, normalized=${discountPercent}`);

                const salesOrg = currentImage.businessArea.salesOrganisationDisplayId;
                const distributionChannel = currentImage.businessArea.distributionChannel;
                const division = currentImage.businessArea.division;
                const salesOffice = currentImage.businessArea.salesOfficeDisplayId;

                const sellingPriceValue = pricing.sellingPrice ?? 0;
                const costPriceValue = pricing.costPrice ?? 0;
                const isBelowCost = sellingPriceValue < costPriceValue;

                console.log(
                    "Price comparison → Selling:", sellingPriceValue,
                    "Cost:", costPriceValue,
                    "Below cost?", isBelowCost
                );

                let approvalLevelCode = '00';
                let approverRules = [];
                let approvers = [];
                console.log("4.Approval matrix Extracted Header discount:", discountPercent);

                if (discountPercent === 0) {
                    approvalLevelCode = '00';
                }
                else if (isBelowCost) {
                    // OVERRIDE CASE → Selling < Cost
                    console.log("4.Selling price below cost → forcing all approval levels");

                    approverRules = await SELECT.from(DiscountMatrix)
                        .where({
                            salesOrg,
                            distributionChannel,
                            division,
                            salesOffice,
                            active: true
                        })
                        .orderBy("minPercentage asc");

                } else {
                    // NORMAL DISCOUNT-BASED FLOW
                    approverRules = await SELECT.from(DiscountMatrix)
                        .where({
                            salesOrg,
                            distributionChannel,
                            division,
                            salesOffice,
                            active: true
                        })
                        .and("minPercentage <=", discountPercent)
                        .orderBy("minPercentage asc");

                    if (!approverRules.length) {
                        console.log("5.Sales Order No approver found from Discount Matrix");
                    }
                }

                if (discountPercent > 0) {
                    // No approval required
                    if (!approverRules.length) {
                        console.log("5.Sales Order No approver found from Discount Matrix");
                        approvalLevelCode = '00';
                    } else {
                        // Build approver list
                        approvers = approverRules.map(rule => ({
                            partyId: rule.approverEmployeeId,
                            role: rule.approverPartyRole,
                            isMain: true
                        }));

                        // Derive approval level code from approvers
                        const approverCount = approvers?.length;
                        const level = Math.min(approverCount, 5);

                        // Convert to 2-digit code: 1 → "01"
                        approvalLevelCode =
                            level > 0 ? String(level).padStart(2, '0') : null;
                    }
                }

                console.log("6.Derived approvalLevelCode:", approvalLevelCode);

                // If approvalLevelCode is 01–04, reassign to '05' (Approval Necessary)
                if (['01', '02', '03', '04'].includes(approvalLevelCode)) {
                    approvalLevelCode = '05';
                    console.log("6.Approval necessary – approvalLevelCode reassigned to '05'");
                }

                // Get current approval level from Sales Order
                const currentLevel = fullOrderPayload?.extensions?.Approval_Level_Order;
                console.log("6.Current Approval_Level_Order:", currentLevel);

                if (ztotChanged || currentLevel !== approvalLevelCode) {
                    // Validate pricing fields before patching
                    if (
                        pricing == null ||
                        pricing.sellingPrice == null ||
                        pricing.costPrice == null ||
                        pricing.discountPercent == null
                    ) {
                        console.warn(
                            "Pricing incomplete. Skipping PATCH. Values:",
                            JSON.stringify(pricing)
                        );
                    } else {
                        // Get order etag for patching
                        let { etag: orderEtag, payload: orderImage } = await getOrderEtag(salesOrderId);

                        // Build PATCH payload for sales order approval level
                        // If SOSubmitforApproval is false, set it to true; otherwise only update Approval_Level_Order
                        const currentSOSubmitforApproval = orderImage?.extensions?.SOSubmitforApproval;
                        // Build PATCH payload for sales order approval level
                        const SOPayload = {
                            id: salesOrderId,
                            extensions: {
                                Approval_Level_Order: approvalLevelCode

                            }
                        };

                        console.log("Sales Order Extension Patch Payload:", JSON.stringify(SOPayload));

                        // Execute PATCH Approval level
                        await patchOrderExtensions(
                            salesOrderId,
                            orderEtag,
                            SOPayload
                        );

                        console.log("Sales Order extension field Approval_Level_Order updated successfully");

                        // Trigger SSE push event
                        await triggerSSEEvent('SalesOrder', salesOrderId);
                    }
                } else {
                    console.log("No ZTOT discount change and approval level unchanged, skipping update");
                }

                return {
                    status: "success",
                    approvalLevelCode: approvalLevelCode,
                    discountPercent: discountPercent,
                    isBelowCost: isBelowCost,
                    approverCount: approvers.length
                };

            } catch (error) {
                console.error("determineApprovalLevel processing failed:", error?.response?.data || error.message);
                return req.error(500, "determineApprovalLevel processing failed");
            }
        });

        // Determine Sales Manager Party and add to Sales Order
        this.on('determineSalesManagerParty', async (req) => {
            console.log("determineSalesManagerParty triggered");
            const { data } = req.data;
            const currentImage = data.currentImage;

            try {
                // ===== VALIDATION =====
                if (!currentImage) {
                    return req.error(400, "Missing Sales Order payload");
                }

                const salesOrderId = currentImage.id;
                const account = currentImage.account;
                const individualCustomer = currentImage.individualCustomer;

                if (!salesOrderId) {
                    return req.error(400, "Missing Sales Order ID");
                }

                if (!account?.id && !individualCustomer?.id) {
                    return req.error(400, "Either Account or Individual Customer must exist");
                }

                // ===== STEP 1: Fetch full Sales Order to get pricing =====
                const { etag: orderEtag, payload: fullOrderPayload } = await getOrderEtag(salesOrderId);
                const pricing = extractHeaderPricing(fullOrderPayload || {});

                // ===== STEP 2: Find Sales Manager (Z05) from discount matrix =====
                const salesManager = await findSalesManagerFromDiscountMatrix(currentImage, pricing);

                if (!salesManager) {
                    console.log("No Sales Manager (Z05) found in discount matrix");
                    return {
                        status: "success",
                        salesManagerParty: null,
                        message: "No Sales Manager (Z05) found in discount matrix"
                    };
                }

                console.log("Found Sales Manager from discount matrix:", salesManager.partyId, salesManager.role);

                // ===== STEP 2.5: Check if Sales Manager (Z05) already exists in Sales Order parties =====
                const existingParties = currentImage.parties || [];
                const existingSalesManager = existingParties.find(party => party.role === "Z05");

                if (existingSalesManager) {
                    console.log("Sales Manager (Z05) already exists in Sales Order parties:", existingSalesManager.partyId);
                    return {
                        status: "success",
                        salesManagerParty: {
                            partyId: existingSalesManager.partyId,
                            partyRole: existingSalesManager.partyRole,
                            employeeUUID: existingSalesManager.partyId
                        },
                        message: "Sales Manager (Z05) already exists in Sales Order, skipping add"
                    };
                }

                // ===== STEP 3: Resolve employee UUID =====
                const sscv2EmployeeSrv = await cds.connect.to('Sscv2EmployeeService');
                let employeeUUID = null;

                try {
                    const employee = await sscv2EmployeeSrv.getEmployeeByDisplayId(salesManager.partyId);
                    if (employee) {
                        employeeUUID = employee.employeeId;
                        console.log("Resolved Sales Manager employee UUID:", employeeUUID);
                    }
                } catch (e) {
                    console.error("Failed to resolve employee UUID:", salesManager.partyId, e.message);
                    return req.error(500, `Failed to resolve employee UUID for ${salesManager.partyId}`);
                }

                if (!employeeUUID) {
                    return req.error(400, `No employee found for displayId ${salesManager.partyId}`);
                }

                // ===== STEP 4: Add Sales Manager party to Sales Order =====
                const partyPayload = {
                    partyId: employeeUUID,
                    role: salesManager.role,
                    isMain: true
                };

                // Get fresh etag for the POST
                const { etag: freshEtag } = await getOrderEtag(salesOrderId);

                await addSalesOrderParty(salesOrderId, freshEtag, partyPayload);

                return {
                    status: "success",
                    salesManagerParty: {
                        partyId: salesManager.partyId,
                        partyRole: salesManager.role,
                        employeeUUID: employeeUUID
                    },
                    message: "Sales Manager party added to Sales Order successfully"
                };

            } catch (error) {
                console.error("determineSalesManagerParty processing failed:", error?.response?.data || error.message);
                return req.error(500, "determineSalesManagerParty processing failed");
            }
        });

        this.on('resetApproval', async (req) => {
            console.log("withdrawApproval triggered");
            const { data } = req.data;
            const DiscountMatrix = 'automotive.discounts.discountMatrix';
            const currentImage = data.currentImage;
            const beforeImage = data.beforeImage;
            let caseId;
            let caseDisplayId;

            //console.log("Incoming SO Payload:", JSON.stringify(req.data));
            // Connect to Case Service using CDS external service
            const caseSrv = await cds.connect.to('Case.Service');

            try {
                if (!currentImage) {
                    return req.error(400, "Missing Sales Order payload");
                }

                // Extract Required Fields
                const salesOrderId = currentImage.id;
                const salesOrderDisplayId = currentImage.displayId;
                const account = currentImage.account;
                const individualCustomer = currentImage.individualCustomer;
                const contact = currentImage.primaryContact;
                const netAmount = currentImage.totalValues?.netAmount?.content;
                const currency = currentImage.totalValues?.netAmount?.currencyCode;
                console.log("reset approval CaseId_Order for this Sales Order:", currentImage?.extensions?.CaseId_Order);
                caseId = currentImage?.extensions?.CaseId_Order;
                if (!salesOrderId) {
                    return req.error(400, "Missing Sales Order ID");
                }

                if (!account?.id && !individualCustomer?.id) {
                    return req.error(400, "Either Account or Individual Customer must exist");
                }

                if (!caseId) {
                    const salesOrderRelations = currentImage.relatedObjects || [];

                    // Case object type (confirm in tenant)
                    const CASE_OBJECT_TYPE = "2886";

                    const existingCaseRelation = salesOrderRelations.filter(rel =>
                        rel.type === CASE_OBJECT_TYPE
                    );

                    for (const rel of existingCaseRelation) {
                        const caseResponse = await caseSrv.send({
                            method: "GET",
                            path: `/cases/${rel.objectId}?$select=id,caseType,status,displayId`
                        });
                        const value = caseResponse?.value;
                        if (value?.caseType === 'Z12' && value?.status != '06') {
                            console.log("Case Type exists for this Sales Order:", value?.caseType);
                            caseId = value.id;
                            caseDisplayId = value.displayId;
                            break;
                        }
                    }
                }
                if (!caseId) {
                    console.log("No Case exists for this Sales Order:");
                    return { status: "No Case exists for this Sales Order" };
                }
                console.log("reset approval Case already exists for this Sales Order:", caseId);
                // Set the case to withdraw approval via API based on PRE/POST conditions
                if (caseId) {

                    const newLineAdded = hasNewLineAdded(beforeImage, currentImage);
                    const discountChanged = isDiscountChanged(beforeImage, currentImage);
                    console.log("newLineAdded for this Sales Order:" + newLineAdded);
                    console.log("discountChanged for this Sales Order:" + discountChanged);

                    if (newLineAdded || discountChanged) {
                        console.log("Approval must be withdrawn due to changes");

                        // Get both PRE and POST approval contexts
                        const preContext = await getApprovalStepContext(caseId, 'PRE');
                        const postContext = await getApprovalStepContext(caseId, 'POST');

                        console.log("PRE context:", preContext?.status, "isSubmitted:", preContext?.isSubmittedForApproval, "isWithdrawn:", preContext?.isApprovalWithdrawn);
                        console.log("POST context:", postContext?.status, "isSubmitted:", postContext?.isSubmittedForApproval, "isWithdrawn:", postContext?.isApprovalWithdrawn);

                        // Check if PRE is completed
                        if (preContext?.status === 'COMPLETED_SUCCESS') {
                            // PRE is completed, withdraw POST if submitted
                            console.log("PRE is completed, checking POST approval for withdrawal");
                            if (postContext && postContext.isSubmittedForApproval &&
                                !postContext.isApprovalWithdrawn) {
                                console.log("Withdraw POST-VSS approval via API");
                                await withdrawCaseApproval(
                                    caseId,
                                    postContext.caseFlowId,
                                    postContext.phaseId,
                                    postContext.stepId,
                                    postContext.etag
                                );
                            } else {
                                console.log("POST-VSS approval not submitted or already withdrawn → skip");
                            }
                        } else {
                            // PRE is NOT completed, withdraw PRE if submitted
                            console.log("PRE is not completed, checking PRE approval for withdrawal");
                            if (preContext && preContext.isSubmittedForApproval &&
                                !preContext.isApprovalWithdrawn) {
                                console.log("Withdraw PRE-VSS approval via API");
                                await withdrawCaseApproval(
                                    caseId,
                                    preContext.caseFlowId,
                                    preContext.phaseId,
                                    preContext.stepId,
                                    preContext.etag
                                );
                            } else {
                                console.log("PRE-VSS approval not submitted or already withdrawn → skip");
                            }
                        }
                    }
                }
                return { status: "success" };

            } catch (error) {
                console.error("Case reset approval processing failed:", error?.response?.data || error.message);
                return req.error(500, "Case reset approval processing failed");
            }
        });

    }
}

module.exports = { salesorderExthook };
