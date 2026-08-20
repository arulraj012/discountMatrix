const cds = require('@sap/cds');
const { executeHttpRequest } = require('@sap-cloud-sdk/http-client');
const destination = { destinationName: "SSC_V2_API" };
const sseDestination = { destinationName: "SSE_Connect" };

// Get approval step context for PRE or POST phase
async function getApprovalStepContext(caseId, phaseType = 'PRE') {
    // phaseType: 'PRE' for Pre-VSS Approval, 'POST' for Post-VSS Approval
    const response = await executeHttpRequest(destination, {
        method: "GET",
        url: `/sap/c4c/api/v1/case-flow-service/caseFlows?caseId=${caseId}`
    });
    console.log("Case Flow Response for caseId:", caseId);
    const flows = response.data?.value || [];

    if (!flows.length) {
        console.warn("No case flow found for case");
        return null;
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
                    console.log(`Found ${phaseType} approval step: status=${step.status}`);
                    return {
                        caseFlowId: flow.id,
                        phaseId: phase.id,
                        stepId: step.id,
                        phaseDescription: phase.description,
                        isSubmittedForApproval: step.isSubmittedForApproval,
                        isApprovalWithdrawn: step.isApprovalWithdrawn,
                        status: step.status,
                        etag: flow.adminData.updatedOn
                    };
                }
            }
        }
    }

    console.warn(`No ${phaseType} approval step found for case ${caseId}`);
    return null;
}

// Check which phase (PRE/POST) was approved and update the appropriate SO extension field
async function checkAndUpdateApprovalStatus(caseId, salesOrderId, approvalStatus) {
    try {
        // Get PRE approval context
        const preContext = await getApprovalStepContext(caseId, 'PRE');
        // Get POST approval context
        const postContext = await getApprovalStepContext(caseId, 'POST');

        console.log("PRE context status:", preContext?.status);
        console.log("POST context status:", postContext?.status);

        let updateField = null;
        let statusValue = null;

        // Map approval status to extension field value
        const statusMap = {
            WITHDRAWN: "WITHDRAWN",
            APPROVED: "APPROVED",
            REJECTED: "REJECTED",
            SUBMITTED:"SUBMITTED"
        };
        statusValue = statusMap[approvalStatus] || null;

        if (!statusValue) {
            console.log("No relevant approval status to update:", approvalStatus);
            return null;
        }

        // Determine which phase triggered the approval status change
        const preStatus = preContext?.status;
        const postStatus = postContext?.status;

        // Logic based on approvalStatus value AND phase statuses:
        // - APPROVED: Check which phase just completed (COMPLETED_SUCCESS)
        // - REJECTED: Check which phase has exception (COMPLETED_EXCEPTION)
        // - WITHDRAWN: Check which phase is in progress (IN_PROGRESS)

        if (statusValue === 'APPROVED') {
            // For APPROVED - check which phase just completed successfully
            if (postStatus === 'COMPLETED_SUCCESS') {
                updateField = 'Post_Approval_Status';
            } else if (preStatus === 'COMPLETED_SUCCESS') {
                updateField = 'Pre_Approval_Status';
            }
        } else if (statusValue === 'REJECTED') {
            // For REJECTED - check which phase has exception
            if (postStatus === 'COMPLETED_EXCEPTION') {
                updateField = 'Post_Approval_Status';
            } else if (preStatus === 'COMPLETED_EXCEPTION') {
                updateField = 'Pre_Approval_Status';
            }
        } else if (statusValue === 'WITHDRAWN') {
            // For WITHDRAWN - check which phase is in progress
            if (postStatus === 'IN_PROGRESS' && preStatus === 'COMPLETED_SUCCESS') {
                updateField = 'Post_Approval_Status';
            } else if (preStatus === 'IN_PROGRESS') {
                updateField = 'Pre_Approval_Status';
            }
        }else if (statusValue === 'SUBMITTED' || statusValue === 'IN_APPROVAL') {
            // For SUBMITTED - check which phase is in progress
            if (postStatus === 'IN_PROGRESS' && preStatus === 'COMPLETED_SUCCESS') {
                updateField = 'Post_Approval_Status';
            } else if (preStatus === 'IN_PROGRESS') {
                updateField = 'Pre_Approval_Status';
            }
        }

        console.log(`Phase determination: PRE=${preStatus}, POST=${postStatus}, status=${statusValue} → updating ${updateField || 'none'}`);

        // Update Sales Order extension
        if (updateField && statusValue) {
            console.log(`Updating Sales Order ${salesOrderId} field ${updateField} to ${statusValue}`);

            const { etag } = await getOrderEtag(salesOrderId);
            await patchOrderExtensions(salesOrderId, etag, {
                id: salesOrderId,
                extensions: {
                    [updateField]: statusValue,
                    ...(statusValue === 'APPROVED' && { Approval_Level_Order: '00' })
                }
            });

            console.log(`Sales Order ${updateField} updated successfully to ${statusValue}`);

            // Trigger SSE push event
            await triggerSSEEvent('SalesOrder', salesOrderId);
            return { field: updateField, value: statusValue };
        }

        return null;
    } catch (error) {
        console.error("checkAndUpdateApprovalStatus failed:", error?.response?.data || error.message);
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
        //console.log("Order Response:", response?.data);

        // Read ETag from response headers
        const etag = response?.data?.value?.adminData?.updatedOn || response?.value?.adminData?.updatedOn;
        const payload = response?.value || response?.data?.value;


        if (!etag) {
            console.error("getorderEtag No ETag found in response!");
            throw new Error("ETag not found");
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
        console.log("patchOrderExtensions ETag:", etag);
        console.log(JSON.stringify(payload, null, 2));
        await executeHttpRequest(
            destination,
            {
                method: "PATCH",
                url,
                headers: {
                    "Content-Type": "application/merge-patch+json",
                    "If-Match": etag
                },
                data: payload
            },
            {
                fetchCsrfToken: false
            }
        );
    }
    catch (error) {

        console.error(
            "patchOrderExtensions:",
            error?.response?.data || error.message
        );
        console.error("patchOrderExtensions error:", error.code);
        console.error("Response:", JSON.stringify(error?.response?.data))
        throw error;
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
        const payload = {
            status: "IN_PROGRESS",
            isSubmittedForApproval: true,
            isApprovalWithdrawn: false,
            requesterNote: "Submitted via API"
        };

        const response = await executeHttpRequest(
            destination,
            {
                method: "PATCH",
                url,
                headers: {
                    "Content-Type": "application/merge-patch+json"
                    // If-Match header removed - not required by case-flow-service API
                },
                data: payload
            },
            {
                fetchCsrfToken: false
            }
        );

        console.log("Approval submitted successfully", url);
        console.log("Response:", response.data);
    } catch (error) {
        console.error(
            "Approval submission failed:",
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

                //console.log("Current Image:", JSON.stringify(currentImage));
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

                    // Check which phase (PRE/POST) was approved and update the appropriate SO extension field
                    console.log("Checking approval status for caseId:", caseId, "approvalStatus:", currapprovalStatus);

                    const updateResult = await checkAndUpdateApprovalStatus(
                        caseId,
                        salesOrderId,
                        currapprovalStatus
                    );

                    if (updateResult) {
                        console.log(`Sales Order ${updateResult.field} updated to ${updateResult.value}`);
                    } else {
                        console.log("No approval status update required");
                    }
                }

                return { status: "success" };



            } catch (error) {
                console.error("syncChangestoSO failed:", error?.response?.data || error.message);
                return req.error(500, "syncChangestoSO failed");
            }

        });

        this.on('submitApproval', async (req) => {
            console.log("submitApproval triggered");
            const { data } = req.data;
            const currentImage = data.currentImage;

            try {
                if (!currentImage) {
                    return req.error(400, "Missing case payload");
                }

                const caseId = currentImage.id;
                const caseType = currentImage.caseType;

                if (caseType != 'Z12') {
                    return { status: "Not relevant Case type" };
                }

                console.log("submitApproval for caseId:", caseId);

                // Get PRE and POST approval contexts
                const preContext = await getApprovalStepContext(caseId, 'PRE');
                const postContext = await getApprovalStepContext(caseId, 'POST');

                console.log("PRE context:", preContext?.status, "isSubmitted:", preContext?.isSubmittedForApproval);
                console.log("POST context:", postContext?.status, "isSubmitted:", postContext?.isSubmittedForApproval);

                // Determine which phase to submit
                // PRE must be COMPLETED_SUCCESS before POST can be submitted
                let approvalContext = null;
                let phaseType = null;

                // Check if PRE phase is completed
                if (preContext?.status === 'COMPLETED_SUCCESS') {
                    // PRE is completed, now check if POST can be submitted
                    const canSubmitPost = !postContext?.isSubmittedForApproval || postContext?.isApprovalWithdrawn;
                    if (postContext && postContext.status !== 'COMPLETED_SUCCESS' && canSubmitPost) {
                        approvalContext = postContext;
                        phaseType = 'POST';
                        console.log("PRE is completed, submitting POST approval");
                    }
                } else {
                    // PRE is NOT completed, only allow PRE submission
                    const canSubmitPre = !preContext?.isSubmittedForApproval || preContext?.isApprovalWithdrawn;
                    if (preContext && canSubmitPre) {
                        approvalContext = preContext;
                        phaseType = 'PRE';
                        console.log("PRE is not completed, submitting PRE approval");
                    }
                }

                if (approvalContext) {
                    console.log(`Submitting ${phaseType} approval for caseId:`, caseId);
                    await submitCaseApproval(
                        caseId,
                        approvalContext.caseFlowId,
                        approvalContext.phaseId,
                        approvalContext.stepId,
                        approvalContext.etag
                    );
                    console.log(`${phaseType} approval submitted successfully`);
                } else {
                    console.log("No approval step available for submission");
                }

                return { status: "success" };

            } catch (error) {
                console.error("submitApproval failed:", error?.response?.data || error.message);
                return req.error(500, "submitApproval failed");
            }
        });
    }
}

module.exports = { caseExthook };

