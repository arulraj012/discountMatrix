const cds = require('@sap/cds');
const { executeHttpRequest } = require('@sap-cloud-sdk/http-client');


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

class caseExthook extends cds.ApplicationService {
    init() {

        this.on('syncChangestoSO', async (req) => {
            console.log("syncChangestoSO triggered");
            const { data } = req.data;
            const DiscountMatrix = 'automotive.discounts.discountMatrix';
            const currentImage = data.currentImage;
            const beforeImage = data.beforeImage;

            try {
                //console.log("Incoming Payload:", JSON.stringify(req.data));

                console.log("Current Image:", JSON.stringify(currentImage));
                if (!currentImage) {
                    return req.error(400, "Missing case payload");
                }

                // 🔹 Extract Required Fields
                const caseId = currentImage.id;
                const caseType = currentImage.caseType;
                const caseDisplayId = currentImage.displayId;
                const currapprovalStatus = currentImage.approvalStatus;
                const oldapprovalStatus = beforeImage.approvalStatus;

                if (caseType != 'Z12') {
                    return { status: "Not relevant Case type" };
                }

                const caseRelations = currentImage.relatedObjects || [];

                // sales order object type (confirm in tenant)
                const SO_OBJECT_TYPE = "2059";

                const existingCaseRelation = caseRelations.find(rel =>
                    rel.type === SO_OBJECT_TYPE
                );

                console.log("Sales order already exists for this Case:", existingCaseRelation.objectId);
                const salesOrderId = existingCaseRelation.objectId;
                if (existingCaseRelation) {

                    // read latest etag        
                    let { etag: orderEtag, payload: OrderImage } = await getOrderEtag(salesOrderId);

                    if (currapprovalStatus !== oldapprovalStatus) {
                        let newPreApprovalStatus = null;

                        const statusMap = {
                            WITHDRAWN: "WITHDRAWN",
                            APPROVED: "APPROVED",
                            REJECTED: "REJECTED"
                        };
                        newPreApprovalStatus = statusMap[currapprovalStatus] || null;

                        if (newPreApprovalStatus) {

                            const patchPayload = {
                                id: salesOrderId,
                                extensions: {
                                    Pre_Approval_Status: newPreApprovalStatus
                                }
                            };

                            await patchOrderExtensions(
                                salesOrderId,
                                orderEtag,
                                patchPayload
                            );

                            console.log("Order Extension Patch Payload:", patchPayload);
                            console.log("Sales order approval status updated successfully");
                        }
                    }
                }

                return { status: "success" };



            } catch (error) {
                console.error("Case creation failed:", error?.response?.data || error.message);
                return req.error(500, "Case creation failed");
            }

        });

    }
}

module.exports = { caseExthook };

