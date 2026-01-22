const cds = require('@sap/cds')
const { executeHttpRequest } = require('@sap-cloud-sdk/http-client');
const RELEVANT_CONDITIONS = ["ZSDP", "VPRS", "QSBP"];
// ===== Helper functions  =====
function extractComparablePricing(image = {}) {
    const priceElements = image.priceElements || [];
    const totalValues = image.totalValues || {};

    const getCond = (type) =>
        priceElements.find(pe => pe.conditionType === type);

    const cost = getCond('QMMC');   // or VPRS
    const discount = getCond('ZSDP');

    return {
        sellingPrice: Number(totalValues?.grossAmount?.content ?? 0),
        sellingCurrency: totalValues?.grossAmount?.currencyCode ?? 'SAR',

        costPrice: Number(cost?.calculatedAmount?.content ?? 0),
        costCurrency:
            cost?.calculatedAmount?.currencyCode ??
            cost?.rateAmount?.currencyCode ??
            'SAR',

        discountPercent: Math.abs(Number(discount?.rateAmount?.content ?? 0))
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

    const getCond = (type) =>
        priceElements.find(pe => pe.conditionType === type);

    const cost = getCond('QMMC');     // Cost price
    const discount = getCond('ZSDP'); // Discount %

    return {
        //  Selling price from TOTAL VALUES grossAmount)
        sellingPrice: totalValues?.grossAmount?.content ?? 0,
        sellingCurrency: totalValues?.grossAmount?.currencyCode ?? 'SAR',

        // Cost price from condition
        costPrice: cost?.calculatedAmount?.content ?? 0,
        costCurrency:
            cost?.calculatedAmount?.currencyCode ??
            cost?.rateAmount?.currencyCode ??
            'SAR',

        // Discount %
        discountPercent: Number(discount?.rateAmount?.content ?? 0)
    };
}

function findPartyByRole(partyId, role, quote) {
    return quote?.parties?.find(p =>
        p.role === role
    );
}

async function getSalesQuoteEtag(salesQuoteSrv, quoteId) {

    const path = `/salesQuotes/${quoteId}`;

    //console.log("[GET ETag] Calling:", path);

    const response = await salesQuoteSrv.send({
        method: "GET",
        path,
        headers: { Accept: "application/json" }
    });

    //console.log("getSalesQuoteEtag Response Body:", JSON.stringify(response));

    // Read ETag from the payload
    const etag = response?.value?.etag;
    const payload = response?.value;


    if (!etag) {
        console.error("getSalesQuoteEtag No ETag found in response!");
        throw new Error("ETag not found");
    }

    //console.log("getSalesQuoteEtag Retrieved ETag:", etag);

    return {
        etag,
        payload
    };
}

async function patchSalesQuoteExtensions(salesQuoteSrv, quoteId, etag, payload) {
    await salesQuoteSrv.send({
        method: 'PATCH',
        path: `/salesQuotes/${quoteId}`,
        headers: {
            'If-Match': etag,
            'Content-Type': 'application/merge-patch+json'
        },
        data: payload
    });
}
async function patchSalesQuoteParty(salesQuoteSrv, quoteId, etag, payload) {

    await salesQuoteSrv.send({
        method: "POST",
        path: `/salesQuotes/${quoteId}/parties`,
        headers: { 'If-Match': etag, "Content-Type": "application/json" },
        data: payload
    });
}
async function deleteSalesQuotePParty(salesQuoteSrv, quoteId, partyUUID, etag) {
    await salesQuoteSrv.send({
        method: 'DELETE',
        path: `/salesQuotes/${quoteId}/parties/${partyUUID}`,
        headers: {
            'If-Match': etag
        }
    });
}

class salesquoteExthook extends cds.ApplicationService {
    init() {

        this.on('SalesQuotePrehook', async (req) => {
            console.log("SalesQuotePrehook event triggered");
        });

        this.on('InitializeSalesQuotePriceExtFields', async (req) => {
            console.log("InitializeSalesQuotePriceExtFields event triggered");
            try {
                //console.log("Incoming Payload:", JSON.stringify(req.data));
                const { data } = req.data;
                const currentImage = data.currentImage;
                const beforeImage = data.beforeImage;

                if (!currentImage) {
                    console.error("Missing 'currentImage' in request data");
                    return req.error(400, "Missing 'currentImage' in request data");
                }
                //console.log("Current Image:", JSON.stringify(currentImage));

                // Connect to Sales Quote Service
                console.log("Connecting to Sales.Quote.Service...");
                const salesQuoteSrv = await cds.connect.to('Sales.Quote.Service');

                const quoteId = currentImage?.id;
                if (!quoteId) {
                    console.error("Missing Sales Quote ID");
                    return req.error(400, "Missing Sales Quote ID");
                }
                console.log("Sales Quote ID:", quoteId);
                //extensions
                const ext = currentImage.extensions || {};

                const Approval_Level = ext?.Approval_Level;
                console.log(" price Extension fields Approval_Level " + Approval_Level);

                if (Approval_Level !== undefined && Approval_Level !== null ) {

                    // Get quote id
                    console.log(` Quote ID: ${quoteId}`);

                    // Build PATCH payload – clear all extension fields
                    const patchPayload = {
                        id: quoteId,
                        extensions: {
                            Approval_Level: "00"
                        }
                    };

                    console.log("Sales quote Extension Patch Payload:", JSON.stringify(patchPayload));
                    //const etag = await getSalesQuoteEtag(salesQuoteSrv, quoteId);
                    let { etag: quoteEtag, payload: quote } =
                        await getSalesQuoteEtag(salesQuoteSrv, quoteId);

                    console.log("patchSalesQuoteExtensions ETag received:", quoteEtag);

                    // Execute PATCH

                    await patchSalesQuoteExtensions(
                        salesQuoteSrv,
                        quoteId,
                        quoteEtag,
                        patchPayload
                    );

                    console.log("Sales Quote price extension fields updated successfully");
                }


            } catch (e) {
                console.error("InitializeSalesQuotePriceExtFields handler failed:", e?.message || e);
                return req.error(500, "Internal error in SalesQuoteAutoflow handler");
            }


        });


        this.on('SalesQuoteAutoflow', async (req) => {
            console.log("SalesQuoteAutoflow event triggered");

            const { data } = req.data;
            const DiscountMatrix = 'automotive.discounts.discountMatrix';


            try {
                //console.log("Incoming Payload:", JSON.stringify(req.data));

                const currentImage = data.currentImage;
                const beforeImage = data.beforeImage;

                if (!currentImage) {
                    console.error("Missing 'currentImage' in request data");
                    return req.error(400, "Missing 'currentImage' in request data");
                }
                //console.log("Current Image:", JSON.stringify(currentImage));

                // Connect to Sales Quote Service
                console.log("Connecting to Sales.Quote.Service...");
                const salesQuoteSrv = await cds.connect.to('Sales.Quote.Service');

                const quoteId = currentImage?.id;
                if (!quoteId) {
                    console.error("Missing Sales Quote ID");
                    return req.error(400, "Missing Sales Quote ID");
                }
                console.log("Sales Quote ID:", quoteId);
                // Extract pricing
                const pricing = extractHeaderPricing(currentImage || []);
                console.log("1. Extracted Header Pricing:", pricing);

                const pricingChanged = isRelevantPricingChanged(
                    beforeImage || [],
                    currentImage || []
                );
                console.log("2.Sales Quote is pricingChanged:", pricingChanged);


                // determine approvers from discount matrix
                // --------------------------------------------------
                // 1. Fetch ALL matching approvers
                // --------------------------------------------------
                const rawDiscount = pricing.discountPercent;
                // Always use positive discount for approval logic
                const discountPercent = Math.abs(Number(rawDiscount) || 0);

                console.log(`Discount normalization: raw=${rawDiscount}, normalized=${discountPercent}`);

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
                        console.log("5.Sales Quote No approver found from Discount Matrix");
                    }
                }
                if (discountPercent > 0) {
                    // No approval required
                    if (!approverRules.length) {
                        console.log("5.Sales Quote No approver found from Discount Matrix");
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
                const currentLevel = currentImage?.extensions?.Approval_Level;
                console.log("6.Sales Quote  approver currentLevel" + currentLevel);
                console.log("6.Sales Quote  approver approvalLevelCode" + approvalLevelCode);

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

                    // console.log("Pricing values are valid. Proceeding with PATCH...");

                    // Get ETag
                    console.log(` Quote ID: ${quoteId}`);


                    // Build PATCH payload
                    const patchPayload = {
                        id: quoteId,
                        extensions: {
                            Approval_Level: approvalLevelCode
                        }
                    };

                    console.log("Sales quote Extension Patch Payload:", JSON.stringify(patchPayload));
                    //const etag = await getSalesQuoteEtag(salesQuoteSrv, quoteId);
                    let { etag: quoteEtag, payload: quote } =
                        await getSalesQuoteEtag(salesQuoteSrv, quoteId);

                    console.log("7.patchSalesQuoteExtensions ETag received:", quoteEtag);

                    // Execute PATCH

                    await patchSalesQuoteExtensions(
                        salesQuoteSrv,
                        quoteId,
                        quoteEtag,
                        patchPayload
                    );

                    console.log("8.Sales Quote price extension fields updated successfully");
                }

                // --------------------------------------------------
                //  Assign approvers to Sales Quote (V2 API)
                // --------------------------------------------------
                const sscv2EmployeeSrv = await cds.connect.to('Sscv2EmployeeService');
                for (const approver of approvers) {
                    console.log("9.Sales Quote  approver info found from Discount Matrix " + approver.role, approver.partyId);

                    // --------------------------------------------------
                    //  Fetch Employee UUID from Sales Cloud V2
                    // --------------------------------------------------
                    let approverEmployeeUUID;
                    if (approver.partyId) {
                        try {
                            const employee = await sscv2EmployeeSrv.getEmployeeByDisplayId(approver.partyId);
                            console.log("SalesQuoteAutoflow employee" + employee);
                            if (!employee) {
                                req.error(
                                    400,
                                    `No employee found in Sales Cloud for employeeId ${approver.partyId}`
                                );
                            } else {
                                approverEmployeeUUID = employee.employeeId;
                            }

                        } catch (e) {
                            req.error(400, e.message);
                        }
                    }
                    console.log("approverEmployeeUUID:", approverEmployeeUUID);
                    if (approverEmployeeUUID) {
                        // Get ETag
                        console.log(`Fetching ETag for Quote ID: ${quoteId}`);
                        let { etag, payload: quote } =
                            await getSalesQuoteEtag(salesQuoteSrv, quoteId);
                        console.log("ETag received:", etag);

                        console.log("Sales Quote Approver approver partyId" + approver.partyId);
                        // Check existing party role
                        const existingParty = findPartyByRole(approver.partyId, approver.role, currentImage);

                        //  Delete existing approver (same role)
                        if (existingParty) {
                            console.log("10.Sales Quote Approver existingParty" + existingParty.partyDisplayId, existingParty.role);


                            if (existingParty.partyDisplayId != approver.partyId) {
                                console.log(`Deleting existing party for role ${approver.role}`);

                                await deleteSalesQuotePParty(
                                    salesQuoteSrv,
                                    quoteId,
                                    existingParty.id,   // <-- party ID
                                    etag
                                );

                            }
                        }
                        // add new party role
                        if (!existingParty || (existingParty.partyDisplayId != approver.partyId)) {
                            console.log(`11.Add new  party for role ${approver.role}`);
                            // Re-fetch ETag after DELETE
                            let { etag: quoteEtag, payload: quote } = await getSalesQuoteEtag(salesQuoteSrv, quoteId);
                            // Check existing party role
                            const knownParty = findPartyByRole(approver.partyId, approver.role, quote);
                            if (!knownParty || (knownParty.partyDisplayId != approver.partyId)) {
                                //new party payload
                                const partyPayload = {
                                    partyId: approverEmployeeUUID,
                                    role: approver.role,
                                    isMain: true
                                }

                                console.log("Sales quote Party Payload:", JSON.stringify(partyPayload));

                                // Execute New Party POST
                                await patchSalesQuoteParty(
                                    salesQuoteSrv,
                                    quoteId,
                                    quoteEtag,
                                    partyPayload
                                );
                                console.log("Sales Quote Approver Party  updated successfully" + approver.role);
                            }
                        }
                    }

                }

                return { status: "success" };

            } catch (e) {
                console.error("SalesQuoteAutoflow handler failed:", e?.message || e);
                return req.error(500, "Internal error in SalesQuoteAutoflow handler");
            }

        });


    }
}

module.exports = { salesquoteExthook }