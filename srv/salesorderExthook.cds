@protocol: 'rest'
@cds.server.body_parser.limit : '20mb'      // <<< FIX: increase payload limit for this service

service salesorderExthook @(path: '/api/salesorderExthook') {
  @open
  type object {};
  action SalesOrderPrehook(entity: String, beforeImage: object, currentImage: object, skipValidations: Boolean, context: object)                                 returns object;  
 
  action createCaseAutoflow(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;

   action withdrawApproval(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;


}
