const cds = require('@sap/cds')

// Transform organizational unit data to sales organization format
function toSalesOrganization(data) {
    return {
        SalesOrgCode: data.displayId,
        SalesOrgName: data.name || data.displayId
    };
}

// This service provides helper functions for organizational unit data
// The main entities (SalesOrganizations, DistributionChannels, Divisions) 
// are handled in discount-service.js to avoid duplication
class Sscv2OrgUnitService extends cds.ApplicationService {
    init() {
        // Function handler for getSalesOrganizations (used by other services)
        this.on('getSalesOrganizations', async (req) => {
            try {
                const orgUnitApi = await cds.connect.to("Organizational.Unit.Service");
                
                // Build the filter - only filter by isSalesOrganization and ACTIVE status
                const filterString = `currentFunctions/isSalesOrganization eq true and lifeCycleStatus eq ACTIVE`;
                
                // Build the URL path with query parameters
                const url = `/organizationalUnits?$filter=${filterString}&$select=displayId,externalId,externalIds,id,name,validFrom,validTo&$top=100&$orderby=name asc&$count=true`;
                
                // Use simple send() with method and path
                const response = await orgUnitApi.send('GET', url);
                
                // Handle different response formats
                let data = [];
                if (response) {
                    if (Array.isArray(response)) {
                        data = response;
                    } else if (response.value && Array.isArray(response.value)) {
                        data = response.value;
                    } else if (typeof response === 'object' && !response.error) {
                        if (response.displayId) {
                            data = [response];
                        }
                    }
                }
                
                if (data.length > 0) {
                    return data.map(toSalesOrganization);
                }
                
                return [];
            } catch (err) {
                console.error("Error in getSalesOrganizations:", err.message);
                return req.reject(500, "Failed to fetch sales organizations from Sales Cloud V2");
            }
        });

        return super.init();
    }
}

module.exports = { Sscv2OrgUnitService }