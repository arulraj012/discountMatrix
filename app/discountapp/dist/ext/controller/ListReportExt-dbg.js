sap.ui.define([
    "sap/m/MessageBox",
    "sap/m/MessageToast",
    "sap/m/Dialog",
    "sap/m/Button",
    "sap/m/VBox",
    "sap/m/Label",
    "sap/ui/unified/FileUploader",
    "sap/ui/core/BusyIndicator"
], function (MessageBox, MessageToast, Dialog, Button, VBox, Label, FileUploader, BusyIndicator) {
    "use strict";

    // Store references at module level for access across functions
    var _oUploadDialog = null;
    var _oFileUploader = null;
    var _oModel = null;
    var _oExtensionAPI = null;

    /**
     * Handle the upload action
     */
    function handleUpload() {
        if (!_oFileUploader) {
            MessageBox.error("File uploader not initialized.");
            return;
        }

        var sFileName = _oFileUploader.getValue();

        if (!sFileName) {
            MessageBox.error("Please select a file to upload.");
            return;
        }

        // Get the file from the FileUploader's DOM element
        var oDomRef = _oFileUploader.getDomRef();
        var oFileInput = oDomRef ? oDomRef.querySelector('input[type="file"]') : null;
        var oFile = oFileInput && oFileInput.files ? oFileInput.files[0] : null;

        if (!oFile) {
            MessageBox.error("No file selected. Please browse and select a CSV file.");
            return;
        }

        // Read the file
        var oReader = new FileReader();
        oReader.onload = function (e) {
            var sContent = e.target.result;
            processFileContent(sContent, sFileName);
        };
        oReader.onerror = function () {
            MessageBox.error("Error reading file.");
        };

        oReader.readAsText(oFile);
    }

    /**
     * Process the CSV file content and call the uploadDiscountCSV action
     * @param {string} sContent - File content
     * @param {string} sFileName - File name
     */
    function processFileContent(sContent, sFileName) {
        if (!sContent || sContent.trim().length === 0) {
            MessageBox.error("File is empty or has no data.");
            return;
        }

        // Convert CSV content to Base64 for the CDS action
        var sBase64Content = "data:text/csv;base64," + btoa(unescape(encodeURIComponent(sContent)));

        // Call the uploadDiscountCSV action
        callUploadAction(sBase64Content);
    }

    /**
     * Call the uploadDiscountCSV CDS action
     * @param {string} sCsvContent - Base64 encoded CSV content
     */
    function callUploadAction(sCsvContent) {
        var oModel = _oModel;
        
        if (!oModel) {
            MessageBox.error("Data model not available. Please refresh the page and try again.");
            return;
        }

        // Show busy indicator
        BusyIndicator.show(0);

        // Create action binding for uploadDiscountCSV
        var oActionBinding = oModel.bindContext("/uploadDiscountCSV(...)");
        oActionBinding.setParameter("csvContent", sCsvContent);

        oActionBinding.execute().then(function () {
            var oResult = oActionBinding.getBoundContext().getObject();
            
            BusyIndicator.hide();
            
            if (_oUploadDialog) {
                _oUploadDialog.close();
            }

            var iSuccessCount = oResult.successCount || 0;
            var iErrorCount = oResult.errorCount || 0;
            var aErrors = oResult.errors || [];

            if (iErrorCount === 0) {
                MessageToast.show(iSuccessCount + " records uploaded successfully.");
            } else {
                var sErrorMessage = iSuccessCount + " records uploaded successfully.\n" +
                    iErrorCount + " records failed.";
                
                if (aErrors.length > 0) {
                    sErrorMessage += "\n\nErrors:\n" + aErrors.slice(0, 5).join("\n");
                    if (aErrors.length > 5) {
                        sErrorMessage += "\n... and " + (aErrors.length - 5) + " more errors";
                    }
                }
                
                MessageBox.warning(sErrorMessage);
            }

            // Refresh the model
            oModel.refresh();
        }).catch(function (oError) {
            BusyIndicator.hide();
            console.error("Upload error:", oError);
            MessageBox.error("Error uploading file: " + (oError.message || "Unknown error"));
        });
    }

    /**
     * Handle logout - redirect to logout endpoint
     */
    function handleLogout() {
        // Show confirmation dialog before logout
        MessageBox.confirm("Are you sure you want to log out?", {
            title: "Confirm Logout",
            onClose: function (oAction) {
                if (oAction === MessageBox.Action.OK) {
                    // Clear any local storage or session data
                    try {
                        sessionStorage.clear();
                        localStorage.removeItem("sap-ui-language");
                    } catch (e) {
                        console.log("Error clearing storage:", e);
                    }
                    
                    // Determine logout URL based on environment
                    var sLogoutUrl = "/logout";
                    var sCurrentHost = window.location.host;
                    var sCurrentPath = window.location.pathname;
                    
                    // Check if running locally (localhost or 127.0.0.1)
                    var bIsLocal = sCurrentHost.indexOf("localhost") >= 0 || 
                                   sCurrentHost.indexOf("127.0.0.1") >= 0;
                    
                    if (bIsLocal) {
                        // For local development with cds watch
                        // Just redirect to home page and show message
                        MessageToast.show("Logged out successfully (local development)");
                        // Clear OData model cache
                        if (_oModel) {
                            try {
                                _oModel.refresh();
                            } catch (e) {
                                console.log("Error refreshing model:", e);
                            }
                        }
                        // Redirect to home page
                        window.location.href = "/";
                        return;
                    }
                    
                    // For production (SAP BTP/Cloud Foundry with XSUAA)
                    // Check if running behind App Router
                    if (sCurrentPath.indexOf("/cust.discountapp") >= 0 || 
                        sCurrentPath.indexOf("/custdiscountapp") >= 0) {
                        sLogoutUrl = "/do/logout";
                    }
                    
                    // Perform logout by redirecting
                    window.location.href = sLogoutUrl;
                }
            }
        });
    }

    return {
        /**
         * Logout button press handler
         * Logs out the user from the application
         */
        onLogoutPress: function (oBindingContext, aSelectedContexts) {
            handleLogout();
        },

        /**
         * Upload button press handler
         * Opens a dialog to upload CSV file for DiscountMatrix data
         */
        onUploadPress: function (oBindingContext, aSelectedContexts) {
            // Store extension API reference
            _oExtensionAPI = this;
            
            // Get the model from the extension API
            var oModel = null;
            
            // Try different approaches to get the model
            try {
                // In Fiori Elements v4, use editFlow or routing to get the model
                if (this.editFlow && this.editFlow.getView) {
                    oModel = this.editFlow.getView().getModel();
                } else if (this.routing && this.routing.getView) {
                    oModel = this.routing.getView().getModel();
                } else if (this._controller && this._controller.getView) {
                    oModel = this._controller.getView().getModel();
                } else if (this.getModel) {
                    oModel = this.getModel();
                } else if (oBindingContext && oBindingContext.getModel) {
                    oModel = oBindingContext.getModel();
                }
            } catch (e) {
                console.log("Error getting model from extension API:", e);
            }
            
            // Fallback: try to get model from binding context
            if (!oModel && oBindingContext) {
                try {
                    oModel = oBindingContext.getModel();
                } catch (e) {
                    console.log("Error getting model from binding context:", e);
                }
            }
            
            // Fallback: try to get model from selected contexts
            if (!oModel && aSelectedContexts && aSelectedContexts.length > 0) {
                try {
                    oModel = aSelectedContexts[0].getModel();
                } catch (e) {
                    console.log("Error getting model from selected contexts:", e);
                }
            }

            // Fallback: try to get model from sap.ui.getCore()
            if (!oModel) {
                try {
                    var oComponent = sap.ui.getCore().getComponent("container-cust.discountapp");
                    if (oComponent) {
                        oModel = oComponent.getModel();
                    }
                } catch (e) {
                    console.log("Error getting model from component:", e);
                }
            }

            // Log model status for debugging
            console.log("Model obtained:", oModel ? "Yes" : "No");
            
            // Store model reference for later use
            _oModel = oModel;

            // Destroy existing dialog to avoid ID conflicts
            if (_oUploadDialog) {
                _oUploadDialog.destroy();
                _oUploadDialog = null;
            }

            // Create FileUploader with unique ID
            var sFileUploaderId = "fileUploader_" + Date.now();
            _oFileUploader = new FileUploader({
                id: sFileUploaderId,
                name: "discountMatrixFile",
                width: "100%",
                fileType: ["csv"],
                placeholder: "Choose a CSV file...",
                style: "Emphasized",
                uploadOnChange: false,
                buttonOnly: false,
                buttonText: "Browse",
                change: function (oEvent) {
                    var sFileName = oEvent.getParameter("newValue");
                    if (sFileName) {
                        MessageToast.show("File selected: " + sFileName);
                    }
                },
                typeMissmatch: function (oEvent) {
                    MessageBox.error("Please select a CSV file only.");
                }
            });

            // Create upload dialog
            _oUploadDialog = new Dialog({
                title: "Upload Discount Matrix CSV",
                contentWidth: "450px",
                content: [
                    new VBox({
                        items: [
                            new Label({
                                text: "Select a CSV file to upload:",
                                labelFor: sFileUploaderId
                            }).addStyleClass("sapUiSmallMarginTop sapUiSmallMarginBottom"),
                            _oFileUploader
                        ]
                    }).addStyleClass("sapUiSmallMargin")
                ],
                beginButton: new Button({
                    text: "Upload",
                    type: "Emphasized",
                    press: function () {
                        // Call the module-level function directly
                        handleUpload();
                    }
                }),
                endButton: new Button({
                    text: "Cancel",
                    press: function () {
                        _oUploadDialog.close();
                    }
                }),
                afterClose: function () {
                    // Destroy dialog after close to clean up
                    if (_oUploadDialog) {
                        _oUploadDialog.destroy();
                        _oUploadDialog = null;
                    }
                    _oFileUploader = null;
                }
            });
            
            _oUploadDialog.open();
        }
    };
});