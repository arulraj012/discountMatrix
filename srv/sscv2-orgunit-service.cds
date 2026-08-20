using { Organizational.Unit } from './external/SalesSvcCloudV2_organizationalUnitService';

// This service provides helper functions for organizational unit data
// The main entities (SalesOrganizations, DistributionChannels, Divisions) 
// are defined in discount-service.cds to avoid duplication
service Sscv2OrgUnitService @(path: '/api/sscv2OrgUnit') {

  // Function to get all sales organizations (used by other services)
  function getSalesOrganizations() returns array of {
    SalesOrgCode : String;
    SalesOrgName : String;
  };

}