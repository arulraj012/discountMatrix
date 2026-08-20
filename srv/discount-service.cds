using {automotive.discounts as my} from '../db/schema';

@protocol: 'odata'
service DiscountMatrixSrv @(path: '/api/v1') {

  entity BusinessUserRoles    as projection on my.BusinessUserRoles;
  
  // Sales Organizations from Sales Cloud V2 API (data fetched via custom handler)
  @readonly
  entity SalesOrganizations {
    key SalesOrgCode : String(50);
        SalesOrgName : String(100);
  };
  
  // Distribution Channels from Sales Cloud V2 API (data fetched via custom handler)
  @readonly
  entity DistributionChannels {
    key DistChannelCode : String(10);
        DistChannelName : String(255);
  };
  
  // Divisions from Sales Cloud V2 API (data fetched via custom handler)
  @readonly
  entity Divisions {
    key DivisionCode : String(10);
        DivisionName : String(255);
  };
  
  // Sales Offices from Sales Cloud V2 API (data fetched via custom handler)
  @readonly
  entity SalesOffices {
    key SalesOfficeCode : String(50);
        SalesOfficeName : String(100);
  };
  
  // Employees from Sales Cloud V2 API (data fetched via custom handler)
  // Used for Approver Employee ID value help
  @readonly
  entity Employees {
    key EmployeeId   : String(36);  // UUID
        EmployeeDisplayId : String(20);
        EmployeeName : String(255);
  };

  entity DiscountMatrix     as projection on my.discountMatrix {
    *,
    salesOrg || ' / ' || distributionChannel || ' / ' || division || ' / ' || salesOffice as combinedHeader : String,
    businessUserRoleRef,
    approverPartyRoleRef
  };

  entity ApproverPartyRoles as projection on my.ApproverPartyRoles;

  action uploadDiscountCSV(csvContent : LargeString) returns {
    successCount : Integer;
    errorCount   : Integer;
    errors       : array of String;
  };
}