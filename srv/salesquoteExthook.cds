@protocol: 'rest'
@cds.server.body_parser.limit : '20mb'      // <<< FIX: increase payload limit for this service

service salesquoteExthook @(path: '/api/salesquoteExthook') {
  @open
  type object {};
  action SalesQuotePrehook(entity: String, beforeImage: object, currentImage: object, skipValidations: Boolean, context: object)                                 returns object;  
  action InitializeSalesQuotePriceExtFields(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;
  action triggerQuoteDiscountMatrix(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;
  action withdrawApproval(id: String, specversion: String, type: String, source: String, subject: String, time: String, datacontenttype: String, data: object) returns object;

}
