namespace automotive.discounts;

using {
  cuid,
  managed
} from '@sap/cds/common';

type Percentage    : Decimal(5, 2);

// -------------------------------------------------------------
// Value Help Entity
// -------------------------------------------------------------
@Title: 'Business User Roles'
entity BusinessUserRoles {
  key RoleCode : String(50);
      RoleName : String(100);
}

@Title: 'Approver Party Roles'
entity ApproverPartyRoles {
  key RoleCode : String(5);
      RoleName : String(100);
}


// -------------------------------------------------------------
// Approval Level Code List
// -------------------------------------------------------------
type ApprovalLevel : String(2) enum {
  Level01 = '01';
  Level02 = '02';
  Level03 = '03';
  Level04 = '04';
  Level05 = '05';
}

// -------------------------------------------------------------
// Main Entity
// -------------------------------------------------------------
@odata.draft.enabled
@Title: 'Discount Matrix'
entity discountMatrix : cuid, managed {

  @title: 'Sequence Number'
  sequence             : Integer;

  @title                  : 'Approval Level'
  @description            : 'Derived approval level based on number of approvers'
  approvalLevel        : ApprovalLevel;

  @title: 'Sales Organization'
  salesOrg             : String(10);

  @title: 'Distribution Channel'
  distributionChannel  : String(10);

  @title: 'Division'
  division             : String(10);

  @title: 'Sales Office'
  salesOffice          : String(20);

  @title                  : 'Business User Role'
  businessUserRole     : String(100);
  
  // Association to BusinessUserRoles for text display
  businessUserRoleRef  : Association to BusinessUserRoles on businessUserRoleRef.RoleCode = businessUserRole;

  @title                  : 'Approver Party Role'
  @description            : 'Party role code to assign Approver in Sales Cloud V2'
  approverPartyRole    : String(5);
  
  // Association to ApproverPartyRoles for text display
  approverPartyRoleRef : Association to ApproverPartyRoles on approverPartyRoleRef.RoleCode = approverPartyRole;

  @title                  : 'Approver Employee ID'
  @description            : 'Identifier of approver employee in Sales Cloud V2 (e.g., "80001234")'
  @assert.format          : '^\d{1,15}$' // optional validation → allow 1–15 digits
  approverEmployeeId   : String(15);

  @title: 'Approver Employee UUID'
  approverEmployeeUUID : UUID;

  @title: 'Active'
  active               : Boolean default true;

  @title                  : 'Minimum Discount %'
  @assert.range           : [
    0,
    100
  ]
  minPercentage        : Percentage;

  @title                  : 'Maximum Discount %'
  @assert.range           : [
    0,
    100
  ]
  maxPercentage        : Percentage;
}