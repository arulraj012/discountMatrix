using { ![Case] } from './external/SalesSvcCloudV2_case';

@protocol: 'rest'
@cds.server.body_parser.limit : '20mb'      // <<< FIX: increase payload limit for this service

service caseExthook @(path: '/api/caseExthook') {
  @open
  type object {};
  action casePrehook(entity: String, beforeImage: object, currentImage: object, skipValidations: Boolean, context: object)                                 returns object;  
 
  action syncChangestoSO(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;
  
  action submitApproval(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;


}
