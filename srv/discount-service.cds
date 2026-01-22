using {automotive.discounts as my} from '../db/schema';

@protocol: 'rest'
service DiscountMatrixSrv @(path: '/api/v1') {

  entity BusinessUserRoles  as projection on my.BusinessUserRoles;

  entity DiscountMatrix     as projection on my.discountMatrix;

  entity ApproverPartyRoles as projection on my.ApproverPartyRoles;

  action uploadDiscountCSV(csvContent : LargeString) returns {
    successCount : Integer;
    errorCount   : Integer;
    errors       : array of String;
  };
}
