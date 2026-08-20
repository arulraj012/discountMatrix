using { ![Case] } from './external/SalesSvcCloudV2_case';
@protocol: 'rest'
@cds.server.body_parser.limit : '20mb'      // <<< FIX: increase payload limit for this service

service salesorderExthook @(path: '/api/salesorderExthook') {
  @open
  type object {};
  action SalesOrderPrehook(entity: String, beforeImage: object, currentImage: object, skipValidations: Boolean, context: object)                                 returns object;  
 
  action preCaseApproval(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;
   
   action withdrawApproval(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;

   action postCaseApproval(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;

   action finishPreApproval(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;

   action finishPostApproval(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;

   action determineApprovalLevel(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;

   action determineSalesManagerParty(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;

   action resetApproval(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;

}
