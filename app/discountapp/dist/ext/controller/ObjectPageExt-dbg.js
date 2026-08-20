sap.ui.define([
    "sap/ui/core/routing/History"
], function (History) {
    "use strict";

    return {
        /**
         * Back button press handler
         * Navigates back to the List Report page
         */
        onBackPress: function () {
            var oHistory = History.getInstance();
            var sPreviousHash = oHistory.getPreviousHash();

            // Check if there is a previous hash in the browser history
            if (sPreviousHash !== undefined) {
                // Navigate back using browser history
                window.history.go(-1);
            } else {
                // No history available, navigate to the List Report using router
                try {
                    // Try to get the router from the view's component
                    var oView = this.getView();
                    if (oView) {
                        var oComponent = oView.getController().getOwnerComponent();
                        if (oComponent) {
                            var oRouter = oComponent.getRouter();
                            if (oRouter) {
                                oRouter.navTo("DiscountMatrixList", {}, true);
                                return;
                            }
                        }
                    }
                } catch (e) {
                    // Fallback: use browser history
                    console.log("Router navigation failed, using browser history:", e);
                }
                
                // Final fallback: navigate to the root hash
                window.history.go(-1);
            }
        }
    };
});
