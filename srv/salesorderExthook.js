const cds = require('@sap/cds');
const { executeHttpRequest } = require('@sap-cloud-sdk/http-client');
//const RELEVANT_CONDITIONS = ["ZSDP", "VPRS", "QSBP"];
const destination = { destinationName: "SSC_V2_API" };
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

    const priceElements = currentImage.priceElements || [];
    const totalValues = currentImage.totalValues || {};

    // Get single condition
    const getCond = (type) =>
        priceElements.find(pe => pe.conditionType === type);

    // Get all matching conditions
    const getAllConds = (type) =>
        priceElements.filter(pe => pe.conditionType === type);

    const cost = getCond('QMMC'); // Cost price

    // Read all ZTOT rows
    const ztotConditions = getAllConds('ZTOT');

    // Consolidate all percentage values
    const totalDiscountPercent = ztotConditions.reduce((sum, item) => {
        const value = Number(item?.rateAmount?.content ?? 0);
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
        console.log("Order Response:", response?.data);

        //console.log("getcaseEtag Response Body:", JSON.stringify(response));
        // Read ETag from response headers
        const etag = response?.value?.adminData?.updatedOn ||
            response?.adminData?.updatedOn;
        const payload = response?.value;


        if (!etag) {
            console.error("getorderEtag No ETag found in response!");
            //throw new Error("ETag not found");
        }

        console.log("getSalesOrderEtag Retrieved ETag:", etag);
    }
    catch (error) {

        console.error(
            "getOrderEtag:",
            error?.response?.data || error.message
        );

        throw error;
    }
    return {
        etag,
        payload
    };
}
async function patchOrderExtensions(orderId, etag, payload) {
    try {
        const url =
            `/sap/c4c/api/v1/sales-order-service/salesOrders/${OrderId}`;

        const response = await executeHttpRequest(destination, {
            method: "PATCH",
            url,
            headers: {
                "Content-Type": "application/merge-patch+json",
                "If-Match": etag
            },
            data: payload
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

    const rolesToReplace =
        newEmployees.map(e => e.partyRole);

    const filtered = existingEmployees.filter(e =>
        !rolesToReplace.includes(e.partyRole)
    );

    return [
        ...filtered,
        ...newEmployees
    ];
}
async function patchCaseParty(caseSrv, caseId, etag, payload) {

    try {
        const patchPayload = {
            customEmployees: payload
        };
        console.log("patchCaseParty  custom employees Body:", JSON.stringify(patchPayload));

        const response = await caseSrv.send({
            method: "PATCH",
            path: `/cases/${caseId}`,
            headers: { 'If-Match': etag, "Content-Type": "application/merge-patch+json" },
            data: patchPayload
        });

        console.log("Custom Employees updated successfully");

    } catch (error) {

        console.error("Patch failed:", error?.response?.data || error.message);

        return req.error(500, "Case update failed");
    }


}

async function getCaseEtag(caseSrv, caseId) {

    const path = `/cases/${caseId}`;

    const response = await caseSrv.send({
        method: "GET",
        path,
        headers: { Accept: "application/json" }
    });

    //console.log("getcaseEtag Response Body:", JSON.stringify(response));
    //console.log("getcaseEtag Response Header:", JSON.stringify(response?.headers));
    // Read ETag from response headers
    const etag = response?.value?.adminData?.updatedOn ||
        response?.adminData?.updatedOn;
    const payload = response?.value;


    if (!etag) {
        console.error("getcaseEtag No ETag found in response!");
        //throw new Error("ETag not found");
    }

    //console.log("getSalesOrderEtag Retrieved ETag:", etag);

    return {
        etag,
        payload
    };
}

async function patchCaseRelation(caseSrv, caseId, etag, payload) {

    await caseSrv.send({
        method: "POST",
        path: `/cases/${caseId}`,
        headers: { 'If-Match': etag, "Content-Type": "application/json" },
        data: payload
    });
}

async function getApprovalStepContext(caseId) {

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
        for (const step of phase.steps || []) {

            if (step.stepType === "APPROVAL") {

                return {
                    caseFlowId: flow.id,
                    phaseId: phase.id,
                    stepId: step.id,
                    isSubmittedForApproval: step.isSubmittedForApproval,
                    isApprovalWithdrawn: step.isApprovalWithdrawn,
                    status: step.status,
                    etag: flow.adminData.updatedOn
                };
            }
        }
    }


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

        const response = await executeHttpRequest(destination, {
            method: "PATCH",
            url,
            headers: {
                "Content-Type": "application/merge-patch+json",
                "If-Match": etag
            },
            data: {
                status: "IN_PROGRESS",
                isSubmittedForApproval: true,
                requesterNote: "Submitted via API"
            }
        });

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
            console.log("hasNewLineAdded:", hasNewLineAdded);
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

        const response = await executeHttpRequest(destination, {
            method: "PATCH",
            url,
            headers: {
                "Content-Type": "application/merge-patch+json",
                "If-Match": etag
            },
            data: {
                isSubmittedForApproval: false,
                isApprovalWithdrawn: true,
                withdrawalNote: "Approval withdrawn due to discount change"
            }
        });
        console.log("Response:", response.data);
    } catch (error) {

        console.error(
            "Approval submission failed:",
            error?.response?.data || error.message
        );

        throw error;
    }
    console.log("Approval withdrawn successfully");
}
class salesorderExthook extends cds.ApplicationService {
    init() {

        this.on('createCaseAutoflow', async (req) => {
            console.log("createCaseAutoflow triggered");
            const { data } = req.data;
            const DiscountMatrix = 'automotive.discounts.discountMatrix';
            const currentImage = data.currentImage;
            const beforeImage = data.beforeImage;
            let caseId;
            let caseDisplayId;
            const caseSrv = await cds.connect.to('Case.Service');
            try {
                //console.log("Incoming Payload:", JSON.stringify(req.data));

                //console.log("Current Image:", JSON.stringify(currentImage));
                if (!currentImage) {
                    return req.error(400, "Missing Sales Order payload");
                }

                // 🔹 Extract Required Fields
                const salesOrderId = currentImage.id;
                const salesOrderDisplayId = currentImage.displayId;
                const account = currentImage.account;
                const individualCustomer = currentImage.individualCustomer;
                const contact = currentImage.primaryContact;
                const netAmount = currentImage.totalValues?.netAmount?.content;
                const currency = currentImage.totalValues?.netAmount?.currencyCode;

                if (!salesOrderId) {
                    return req.error(400, "Missing Sales Order ID");
                }

                if (!account?.id && !individualCustomer?.id) {
                    return req.error(400, "Either Account or Individual Customer must exist");
                }


                const salesOrderRelations = currentImage.relatedObjects || [];

                // Case object type (confirm in tenant)
                const CASE_OBJECT_TYPE = "2886";

                const existingCaseRelation = salesOrderRelations.filter(rel =>
                    rel.type === CASE_OBJECT_TYPE
                );

                for (const rel of existingCaseRelation) {

                    const { value } = await caseSrv.send({
                        method: "GET",
                        path: `/cases/${rel.objectId}?$select=id,caseType,status`
                    });
                    //console.log("Case exists for this Sales Order:", value);
                    if (value?.caseType === 'Z12' && value?.status != '06') {
                        console.log("Case Type exists for this Sales Order:", value?.caseType);
                        caseId = value.id;
                        caseDisplayId = value.displayId;

                        break;
                    }
                }

                if (caseId) {
                    console.log("Case already exists for this Sales Order:", caseId, caseDisplayId);

                }
                else {
                    //  Create Approval Case 
                    //  Build Business Partner Section Dynamically
                    let businessPartnerSection = {};
                    let contactSection = {};

                    if (account?.id) {

                        businessPartnerSection.account = {
                            id: account.id,
                            displayId: account.displayId
                        };

                        //  Add contact ONLY when account exists
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

                        //  DO NOT add contact when individual customer
                    }


                    //  Build Body for Approval Case Service
                    const caseBody = {
                        subject: `Approval Case for Sales Order ${salesOrderDisplayId}`,
                        priority: "03",             // Ensure valid in tenant
                        origin: "Z07",               // Portal / API
                        caseType: "Z12",          // Ensure valid in tenant
                        status: "01",
                        ...businessPartnerSection,
                        ...contactSection,
                        //  Link Sales Order as Related Object
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

                    // 2 Create Case using POST
                    const createResult = await caseSrv.send({
                        method: "POST",
                        path: `/cases`,
                        headers: {
                            "Content-Type": "application/json"
                        },
                        data: caseBody
                    });

                    //console.log("Case created successfully:", createResult);

                    caseId = createResult?.value?.id;
                    const caseDisplayId = createResult?.value?.displayId;

                    console.log("Case ID:", caseId);
                    console.log("Case Display ID:", caseDisplayId);


                }

                // determine the approval level for Case
                // Extract pricing
                const pricing = extractHeaderPricing(currentImage || []);
                console.log("1. Extracted Header Pricing:", pricing);

                const pricingChanged = isRelevantPricingChanged(
                    beforeImage || [],
                    currentImage || []
                );
                console.log("2.Sales Order is pricingChanged:", pricingChanged);


                // determine approvers from discount matrix
                // --------------------------------------------------
                // 1. Fetch ALL matching approvers
                // --------------------------------------------------
                const rawDiscount = pricing.discountPercent;
                // Always use positive discount for approval logic
                const discountPercent = Math.abs(Number(rawDiscount) || 0);

                console.log(`3.Discount normalization: raw=${rawDiscount}, normalized=${discountPercent}`);

                const salesOrg = currentImage.businessArea.salesOrganisationDisplayId;
                const distributionChannel = currentImage.businessArea.distributionChannel;
                const division = currentImage.businessArea.division;
                const salesOffice = currentImage.businessArea.salesOfficeDisplayId;


                const sellingPriceValue =
                    pricing.sellingPrice ?? 0;

                const costPriceValue =
                    pricing.costPrice ?? 0;

                const isBelowCost = sellingPriceValue < costPriceValue;

                console.log(
                    "Price comparison → Selling:", sellingPriceValue,
                    "Cost:", costPriceValue,
                    "Below cost?", isBelowCost
                );

                let approvalLevelCode = '00';

                let approverRules = [];

                let approvers = [];
                console.log("4.Approval matrix Extracted Header  discount:", discountPercent);

                if (isBelowCost) {
                    //  OVERRIDE CASE → Selling < Cost
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
                    // <-- force all 5 approvers

                    approvalLevelCode = '05';

                } else if (discountPercent === 0) {
                    approvalLevelCode = '00';
                } else {

                    //  NORMAL DISCOUNT-BASED FLOW
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

                        // --------------------------------------------------
                        // 2. Build approver list
                        // --------------------------------------------------                

                        approvers = approverRules.map(rule => ({
                            partyId: rule.approverEmployeeId,
                            role: rule.approverPartyRole,
                            isMain: true
                        }));

                        //Derive approval level code from approvers
                        const approverCount = approvers?.length;

                        const level = Math.min(approverCount, 5);

                        // Convert to 2-digit code: 1 → "01"
                        approvalLevelCode =
                            level > 0 ? String(level).padStart(2, '0') : null;


                    }
                }

                let { etag: caseEtag, payload: caseImage } =
                    await getCaseEtag(caseSrv, caseId);

                console.log("Case current caseEtag ", caseEtag);

                const currentLevel = caseImage?.extensions?.Approval_Level_Case;
                console.log("6.Case  approver currentLevel " + currentLevel);
                console.log("6.Case  approver derived approvalLevelCode " + approvalLevelCode);

                if (pricingChanged || currentLevel !== approvalLevelCode) {

                    // *** Validate pricing fields before patching ***
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

                    // Build PATCH payload for approval level
                    const patchPayload = {
                        id: caseId,
                        extensions: {
                            Approval_Level_Case: approvalLevelCode
                        }
                    };

                    console.log("Case Extension Patch Payload:", JSON.stringify(patchPayload));


                    // Execute PATCH Approval level
                    await patchCaseExtensions(
                        caseSrv,
                        caseId,
                        caseEtag,
                        patchPayload
                    );

                    console.log("8.case price extension fields approval level updated successfully");
                }

                // --------------------------------------------------
                //  Assign approvers to Sales Order (V2 API)
                // --------------------------------------------------
                const sscv2EmployeeSrv = await cds.connect.to('Sscv2EmployeeService');
                const newCustomEmployees = [];
                for (const approver of approvers) {
                    console.log("9.Case  approver info found from Discount Matrix " + approver.role, approver.partyId);

                    // --------------------------------------------------
                    //  Fetch Employee UUID from Sales Cloud V2
                    // --------------------------------------------------
                    let approverEmployeeUUID;
                    if (approver.partyId) {
                        try {
                            const employee = await sscv2EmployeeSrv.getEmployeeByDisplayId(approver.partyId);
                            console.log("SalesOrder Autoflow Approver employee " + employee.employeeId);
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

                const { etag, payload: casePayload } = await getCaseEtag(caseSrv, caseId);

                const existingCustomEmployees = casePayload?.customEmployees || [];

                console.log("existingCustomEmployees Body:", JSON.stringify(existingCustomEmployees));

                const mergedEmployees = mergeCustomEmployees(
                    existingCustomEmployees,
                    newCustomEmployees
                );


                // Execute customEmployees patch
                await patchCaseParty(
                    caseSrv,
                    caseId,
                    caseEtag,
                    mergedEmployees
                );
                // Set the case to submit for approval via API
                if (caseId) {
                    console.log("Set the case to submit for approval via API");
                    const approvalContext = await getApprovalStepContext(caseId);
                    //console.log("approvalContext Body:", JSON.stringify(approvalContext));
                    // Check if already submitted
                    if (approvalContext.isSubmittedForApproval &&
                        !approvalContext.isApprovalWithdrawn &&
                        approvalContext.status === "IN_PROGRESS") {
                        console.log("Already submitted → skip");
                    } else {
                        console.log("submit the case for approval via API");
                        await submitCaseApproval(
                            caseId,
                            approvalContext.caseFlowId,
                            approvalContext.phaseId,
                            approvalContext.stepId,
                            etag
                        );
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
            const caseSrv = await cds.connect.to('Case.Service');
            try {
                //console.log("Incoming Payload:", JSON.stringify(req.data));

                //console.log("Current Image:", JSON.stringify(currentImage));
                if (!currentImage) {
                    return req.error(400, "Missing Sales Order payload");
                }

                // 🔹 Extract Required Fields
                const salesOrderId = currentImage.id;
                const salesOrderDisplayId = currentImage.displayId;
                const account = currentImage.account;
                const individualCustomer = currentImage.individualCustomer;
                const contact = currentImage.primaryContact;
                const netAmount = currentImage.totalValues?.netAmount?.content;
                const currency = currentImage.totalValues?.netAmount?.currencyCode;

                if (!salesOrderId) {
                    return req.error(400, "Missing Sales Order ID");
                }

                if (!account?.id && !individualCustomer?.id) {
                    return req.error(400, "Either Account or Individual Customer must exist");
                }


                const salesOrderRelations = currentImage.relatedObjects || [];

                // Case object type (confirm in tenant)
                const CASE_OBJECT_TYPE = "2886";

                const existingCaseRelation = salesOrderRelations.filter(rel =>
                    rel.type === CASE_OBJECT_TYPE
                );

                for (const rel of existingCaseRelation) {

                    const { value } = await caseSrv.send({
                        method: "GET",
                        path: `/cases/${rel.objectId}?$select=id,caseType,status`
                    });
                    //console.log("Case exists for this Sales Order:", value);
                    if (value?.caseType === 'Z12' && value?.status != '06') {
                        console.log("Case Type exists for this Sales Order:", value?.caseType);
                        caseId = value.id;
                        caseDisplayId = value.displayId;

                        break;
                    }
                }

                if (!caseId) {
                    console.log("No Case exists for this Sales Order:");
                }

                // Set the case to submit for approval via API
                if (caseId) {
                    console.log("Case already exists for this Sales Order:", caseId, caseDisplayId);
                    const newLineAdded = hasNewLineAdded(beforeImage, currentImage);
                    const discountChanged = isDiscountChanged(beforeImage, currentImage);
                    console.log("newLineAdded for this Sales Order:" + newLineAdded);
                    console.log("discountChanged for this Sales Order:" + discountChanged);
                    if (newLineAdded || discountChanged) {
                        console.log("Approval must be withdrawn");

                        console.log("Set the case to withdraw approval via API");
                        const approvalContext = await getApprovalStepContext(caseId);
                        // Check if already submitted
                        if (approvalContext.isSubmittedForApproval &&
                            !approvalContext.isApprovalWithdrawn) {
                            console.log("Withdraw the case for approval via API");
                            await withdrawCaseApproval(
                                caseId,
                                approvalContext.caseFlowId,
                                approvalContext.phaseId,
                                approvalContext.stepId,
                                approvalContext.etag
                            );

                        }

                    }
                }
                return { status: "success" };

            } catch (error) {
                console.error("Case withdraw approval processing failed:", error?.response?.data || error.message);
                return req.error(500, "Case withdraw approval processing failed");
            }

        });

    }
}

module.exports = { salesorderExthook };

