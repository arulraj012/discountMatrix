/* checksum : 9ba7f340261d4a130bef468a92a7bdc9 */
namespace ![Case];

@Capabilities.BatchSupported : false
@Capabilities.KeyAsSegmentSupported : true
@Core.Description : 'Case Service'
@Core.SchemaVersion : '1.0.0'
@Core.LongDescription : `Cases are records of service or support requests from an account or individual customer used to track interactions with the requestor. Cases also record details like how much time has passed since the case was created, what actions were taken to resolve the issue, priority or associated products, and much more.

Use this API to view, create, and manage your cases.`
service Service {
  @Common.Label : 'Case'
  @Core.Description : 'Read data'
  @Core.LongDescription : 'Specify query parameters to return desired case records from the system.'
  @openapi.path : '/sap/c4c/api/v1/case-service/cases'
  function sap_c4c_api_v1_case_service_cases(
    @openapi.in : 'header'
    @openapi.required : true
    @openapi.name : 'x-sap-crm-token'
    x_sap_crm_token : String,
    @description : 'Show only the first n cases.'
    @openapi.in : 'query'
    @openapi.name : '$top'
    _top : Integer,
    @description : 'Skip the first n cases.'
    @openapi.in : 'query'
    @openapi.name : '$skip'
    _skip : Integer,
    @description : 'Search for a string within case.'
    @openapi.in : 'query'
    @openapi.name : '$search'
    _search : String,
    @description : 'Order cases by attribute.'
    @openapi.in : 'query'
    @openapi.name : '$orderby'
    _orderby : String,
    @description : 'Filter cases by attribute.'
    @openapi.in : 'query'
    @openapi.name : '$filter'
    _filter : String,
    @description : 'Select attributes to be returned.'
    @openapi.in : 'query'
    @openapi.name : '$select'
    _select : String,
    @description : 'Exclude attributes from response.'
    @openapi.in : 'query'
    @openapi.name : '$exclude'
    _exclude : String,
    @description : 'Indicates if count of cases to be returned.'
    @openapi.in : 'query'
    @openapi.name : '$count'
    _count : Boolean,
    @description : 'Indicates the query to be used by case service.'
    @openapi.in : 'query'
    @openapi.name : '$query'
    _query : String
  ) returns
    @title : 'Case query response'
    {
      count : Integer;
      value : many {
        id : UUID;
        displayId : String;
        subject : String;
        priority : String;
        priorityDescription : String;
        origin : String;
        caseType : String;
        caseTypeDescription : String;
        status : String;
        statusDescription : String;
        escalationStatus : String;
        registeredProducts : many {
          id : UUID;
          displayId : String;
          serialId : String;
        };
        functionalLocations : many {
          id : UUID;
          displayId : String;
        };
        productInstallPoints : many {
          id : UUID;
          displayId : String;
        };
        installedBases : many {
          id : UUID;
          displayId : String;
        };
        account : {
          id : UUID;
          displayId : String;
          name : String;
          country : String;
          state : String;
          streetPostalCode : String;
        };
        contact : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
          phoneNumber : String;
        };
        individualCustomer : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        processor : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        approvers : many {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        serviceTeam : {
          id : UUID;
          displayId : String;
          name : String;
        };
        description : {
          noteId : UUID;
          content : String;
        };
        notes : many {
          noteId : UUID;
          id : UUID;
          content : String;
        };
        relatedObjects : many {
          objectId : UUID;
          type : String;
          role : String;
        };
        timePoints : {
          reportedOn : Timestamp;
          escalatedOn : Timestamp;
          completedOn : Timestamp;
          completionDueOn : Timestamp;
          assignedToCustomerOn : Timestamp;
          assignedToProcessorOn : Timestamp;
          initialReviewDueOn : Timestamp;
          initialReviewCompletedOn : Timestamp;
          resolutionDueOn : Timestamp;
          responseDueOn : Timestamp;
          closedOn : Timestamp;
        };
        categoryLevel1 : {
          id : UUID;
          displayId : String;
        };
        categoryLevel2 : {
          id : UUID;
          displayId : String;
        };
        serviceLevelId : UUID;
        durationTerms : {
          durationWithAgent : Timestamp;
          durationWithCustomer : Timestamp;
        };
        isRead : Boolean;
        isEndOfPurpose : Boolean;
        isDepersonalized : Boolean;
        adminData : {
          createdBy : UUID;
          createdByName : String;
          createdOn : Timestamp;
          updatedBy : UUID;
          updatedByName : String;
          updatedOn : Timestamp;
        };
        extensions : { };
      };
      info : {
        code : String;
        details : many {
          message : String;
          target : String;
          code : String;
        };
        message : String;
        target : String;
      };
    };

  @Common.Label : 'Case'
  @Core.Description : 'Create data'
  @Core.LongDescription : 'Send case information to the system to create a new case entity.'
  @openapi.path : '/sap/c4c/api/v1/case-service/cases'
  action sap_c4c_api_v1_case_service_cases_post(
    @openapi.in : 'header'
    @openapi.required : true
    @openapi.name : 'x-sap-crm-token'
    x_sap_crm_token : String,
    @title : 'Case create request'
    @openapi.in : 'body'
    body : {
      subject : String;
      priority : String;
      origin : String;
      caseType : String;
      status : String;
      escalationStatus : String;
      registeredProducts : many {
        id : UUID;
        displayId : String;
        serialId : String;
      };
      functionalLocations : many {
        id : UUID;
        displayId : String;
      };
      productInstallPoints : many {
        id : UUID;
        displayId : String;
      };
      installedBases : many {
        id : UUID;
        displayId : String;
      };
      account : {
        id : UUID;
        displayId : String;
        name : String;
        country : String;
        state : String;
        streetPostalCode : String;
      };
      contact : {
        id : UUID;
        displayId : String;
        name : String;
        emailId : String;
        phoneNumber : String;
      };
      individualCustomer : {
        id : UUID;
        displayId : String;
        name : String;
        emailId : String;
      };
      processor : {
        id : UUID;
        displayId : String;
        name : String;
        emailId : String;
      };
      approvers : many {
        id : UUID;
        displayId : String;
        name : String;
        emailId : String;
      };
      serviceTeam : {
        id : UUID;
        displayId : String;
        name : String;
      };
      description : {
        noteId : UUID;
        content : String;
      };
      notes : many {
        noteId : UUID;
        id : UUID;
        content : String;
      };
      timePoints : {
        reportedOn : Timestamp;
        escalatedOn : Timestamp;
        completedOn : Timestamp;
        completionDueOn : Timestamp;
        assignedToCustomerOn : Timestamp;
        assignedToProcessorOn : Timestamp;
        initialReviewDueOn : Timestamp;
        initialReviewCompletedOn : Timestamp;
        resolutionDueOn : Timestamp;
        responseDueOn : Timestamp;
        closedOn : Timestamp;
      };
      categoryLevel1 : {
        id : UUID;
        displayId : String;
      };
      categoryLevel2 : {
        id : UUID;
        displayId : String;
      };
      extensions : { };
    }
  ) returns
    @title : 'Case post response'
    {
      value : {
        id : UUID;
        displayId : String;
        subject : String;
        priority : String;
        priorityDescription : String;
        origin : String;
        caseType : String;
        caseTypeDescription : String;
        status : String;
        statusDescription : String;
        escalationStatus : String;
        registeredProducts : many {
          id : UUID;
          displayId : String;
          serialId : String;
        };
        functionalLocations : many {
          id : UUID;
          displayId : String;
        };
        productInstallPoints : many {
          id : UUID;
          displayId : String;
        };
        installedBases : many {
          id : UUID;
          displayId : String;
        };
        account : {
          id : UUID;
          displayId : String;
          name : String;
          country : String;
          state : String;
          streetPostalCode : String;
        };
        contact : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
          phoneNumber : String;
        };
        individualCustomer : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        processor : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        approvers : many {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        serviceTeam : {
          id : UUID;
          displayId : String;
          name : String;
        };
        description : {
          noteId : UUID;
          content : String;
        };
        notes : many {
          noteId : UUID;
          id : UUID;
          content : String;
        };
        relatedObjects : many {
          objectId : UUID;
          type : String;
          role : String;
        };
        timePoints : {
          reportedOn : Timestamp;
          escalatedOn : Timestamp;
          completedOn : Timestamp;
          completionDueOn : Timestamp;
          assignedToCustomerOn : Timestamp;
          assignedToProcessorOn : Timestamp;
          initialReviewDueOn : Timestamp;
          initialReviewCompletedOn : Timestamp;
          resolutionDueOn : Timestamp;
          responseDueOn : Timestamp;
          closedOn : Timestamp;
        };
        categoryLevel1 : {
          id : UUID;
          displayId : String;
        };
        categoryLevel2 : {
          id : UUID;
          displayId : String;
        };
        serviceLevelId : UUID;
        durationTerms : {
          durationWithAgent : Timestamp;
          durationWithCustomer : Timestamp;
        };
        isRead : Boolean;
        isEndOfPurpose : Boolean;
        isDepersonalized : Boolean;
        adminData : {
          createdBy : UUID;
          createdByName : String;
          createdOn : Timestamp;
          updatedBy : UUID;
          updatedByName : String;
          updatedOn : Timestamp;
        };
        extensions : { };
      };
      info : {
        code : String;
        details : many {
          message : String;
          target : String;
          code : String;
        };
        message : String;
        target : String;
      };
    };

  @Common.Label : 'Case'
  @Core.Description : 'Read a specific data'
  @Core.LongDescription : 'Query the system for a specific case using the case ID.'
  @openapi.path : '/sap/c4c/api/v1/case-service/cases/{id}'
  function sap_c4c_api_v1_case_service_cases_(
    @openapi.in : 'header'
    @openapi.required : true
    @openapi.name : 'x-sap-crm-token'
    x_sap_crm_token : String,
    @description : 'Case ID'
    @openapi.in : 'path'
    id : UUID
  ) returns
    @title : 'Case read response'
    {
      value : {
        id : UUID;
        displayId : String;
        subject : String;
        priority : String;
        priorityDescription : String;
        origin : String;
        caseType : String;
        caseTypeDescription : String;
        status : String;
        statusDescription : String;
        escalationStatus : String;
        registeredProducts : many {
          id : UUID;
          displayId : String;
          serialId : String;
        };
        functionalLocations : many {
          id : UUID;
          displayId : String;
        };
        productInstallPoints : many {
          id : UUID;
          displayId : String;
        };
        installedBases : many {
          id : UUID;
          displayId : String;
        };
        account : {
          id : UUID;
          displayId : String;
          name : String;
          country : String;
          state : String;
          streetPostalCode : String;
        };
        contact : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
          phoneNumber : String;
        };
        individualCustomer : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        processor : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        approvers : many {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        serviceTeam : {
          id : UUID;
          displayId : String;
          name : String;
        };
        description : {
          noteId : UUID;
          content : String;
        };
        notes : many {
          noteId : UUID;
          id : UUID;
          content : String;
        };
        relatedObjects : many {
          objectId : UUID;
          type : String;
          role : String;
        };
        timePoints : {
          reportedOn : Timestamp;
          escalatedOn : Timestamp;
          completedOn : Timestamp;
          completionDueOn : Timestamp;
          assignedToCustomerOn : Timestamp;
          assignedToProcessorOn : Timestamp;
          initialReviewDueOn : Timestamp;
          initialReviewCompletedOn : Timestamp;
          resolutionDueOn : Timestamp;
          responseDueOn : Timestamp;
          closedOn : Timestamp;
        };
        categoryLevel1 : {
          id : UUID;
          displayId : String;
        };
        categoryLevel2 : {
          id : UUID;
          displayId : String;
        };
        serviceLevelId : UUID;
        durationTerms : {
          durationWithAgent : Timestamp;
          durationWithCustomer : Timestamp;
        };
        isRead : Boolean;
        isEndOfPurpose : Boolean;
        isDepersonalized : Boolean;
        adminData : {
          createdBy : UUID;
          createdByName : String;
          createdOn : Timestamp;
          updatedBy : UUID;
          updatedByName : String;
          updatedOn : Timestamp;
        };
        extensions : { };
      };
      info : {
        code : String;
        details : many {
          message : String;
          target : String;
          code : String;
        };
        message : String;
        target : String;
      };
    };

  @Common.Label : 'Case'
  @Core.Description : 'Create or Update data'
  @Core.LongDescription : 'Add attributes to a specific case by ID.'
  @openapi.method : 'PUT'
  @openapi.path : '/sap/c4c/api/v1/case-service/cases/{id}'
  action sap_c4c_api_v1_case_service_cases__put(
    @openapi.in : 'header'
    @openapi.required : true
    @openapi.name : 'x-sap-crm-token'
    x_sap_crm_token : String,
    @description : 'Case ID'
    @openapi.in : 'path'
    id : UUID,
    @title : 'Case update request'
    @openapi.in : 'body'
    body : {
      subject : String;
      priority : String;
      status : String;
      escalationStatus : String;
      registeredProducts : many {
        id : UUID;
        displayId : String;
        serialId : String;
      };
      functionalLocations : many {
        id : UUID;
        displayId : String;
      };
      productInstallPoints : many {
        id : UUID;
        displayId : String;
      };
      installedBases : many {
        id : UUID;
        displayId : String;
      };
      account : {
        id : UUID;
        displayId : String;
        name : String;
        country : String;
        state : String;
        streetPostalCode : String;
      };
      contact : {
        id : UUID;
        displayId : String;
        name : String;
        emailId : String;
        phoneNumber : String;
      };
      individualCustomer : {
        id : UUID;
        displayId : String;
        name : String;
        emailId : String;
      };
      processor : {
        id : UUID;
        displayId : String;
        name : String;
        emailId : String;
      };
      approvers : many {
        id : UUID;
        displayId : String;
        name : String;
        emailId : String;
      };
      serviceTeam : {
        id : UUID;
        displayId : String;
        name : String;
      };
      description : {
        noteId : UUID;
        content : String;
      };
      notes : many {
        noteId : UUID;
        id : UUID;
        content : String;
      };
      timePoints : {
        reportedOn : Timestamp;
        escalatedOn : Timestamp;
        completedOn : Timestamp;
        completionDueOn : Timestamp;
        assignedToCustomerOn : Timestamp;
        assignedToProcessorOn : Timestamp;
        initialReviewDueOn : Timestamp;
        initialReviewCompletedOn : Timestamp;
        resolutionDueOn : Timestamp;
        responseDueOn : Timestamp;
        closedOn : Timestamp;
      };
      categoryLevel1 : {
        id : UUID;
        displayId : String;
      };
      categoryLevel2 : {
        id : UUID;
        displayId : String;
      };
      extensions : { };
    }
  ) returns
    @title : 'Case put response'
    {
      value : {
        id : UUID;
        displayId : String;
        subject : String;
        priority : String;
        priorityDescription : String;
        origin : String;
        caseType : String;
        caseTypeDescription : String;
        status : String;
        statusDescription : String;
        escalationStatus : String;
        registeredProducts : many {
          id : UUID;
          displayId : String;
          serialId : String;
        };
        functionalLocations : many {
          id : UUID;
          displayId : String;
        };
        productInstallPoints : many {
          id : UUID;
          displayId : String;
        };
        installedBases : many {
          id : UUID;
          displayId : String;
        };
        account : {
          id : UUID;
          displayId : String;
          name : String;
          country : String;
          state : String;
          streetPostalCode : String;
        };
        contact : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
          phoneNumber : String;
        };
        individualCustomer : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        processor : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        approvers : many {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        serviceTeam : {
          id : UUID;
          displayId : String;
          name : String;
        };
        description : {
          noteId : UUID;
          content : String;
        };
        notes : many {
          noteId : UUID;
          id : UUID;
          content : String;
        };
        relatedObjects : many {
          objectId : UUID;
          type : String;
          role : String;
        };
        timePoints : {
          reportedOn : Timestamp;
          escalatedOn : Timestamp;
          completedOn : Timestamp;
          completionDueOn : Timestamp;
          assignedToCustomerOn : Timestamp;
          assignedToProcessorOn : Timestamp;
          initialReviewDueOn : Timestamp;
          initialReviewCompletedOn : Timestamp;
          resolutionDueOn : Timestamp;
          responseDueOn : Timestamp;
          closedOn : Timestamp;
        };
        categoryLevel1 : {
          id : UUID;
          displayId : String;
        };
        categoryLevel2 : {
          id : UUID;
          displayId : String;
        };
        serviceLevelId : UUID;
        durationTerms : {
          durationWithAgent : Timestamp;
          durationWithCustomer : Timestamp;
        };
        isRead : Boolean;
        isEndOfPurpose : Boolean;
        isDepersonalized : Boolean;
        adminData : {
          createdBy : UUID;
          createdByName : String;
          createdOn : Timestamp;
          updatedBy : UUID;
          updatedByName : String;
          updatedOn : Timestamp;
        };
        extensions : { };
      };
      info : {
        code : String;
        details : many {
          message : String;
          target : String;
          code : String;
        };
        message : String;
        target : String;
      };
    };

  @Common.Label : 'Case'
  @Core.Description : 'Update or Modify data'
  @Core.LongDescription : 'Update case attributes in the system.'
  @openapi.method : 'PATCH'
  @openapi.path : '/sap/c4c/api/v1/case-service/cases/{id}'
  action sap_c4c_api_v1_case_service_cases__patch(
    @openapi.in : 'header'
    @openapi.required : true
    @openapi.name : 'x-sap-crm-token'
    x_sap_crm_token : String,
    @description : 'Case ID'
    @openapi.in : 'path'
    id : UUID,
    @title : 'Case patchupdate request'
    @openapi.in : 'body'
    body : {
      subject : String;
      priority : String;
      status : String;
      escalationStatus : String;
      registeredProducts : many {
        id : UUID;
        displayId : String;
        serialId : String;
      };
      functionalLocations : many {
        id : UUID;
        displayId : String;
      };
      productInstallPoints : many {
        id : UUID;
        displayId : String;
      };
      installedBases : many {
        id : UUID;
        displayId : String;
      };
      account : {
        id : UUID;
        displayId : String;
        name : String;
        country : String;
        state : String;
        streetPostalCode : String;
      };
      contact : {
        id : UUID;
        displayId : String;
        name : String;
        emailId : String;
        phoneNumber : String;
      };
      individualCustomer : {
        id : UUID;
        displayId : String;
        name : String;
        emailId : String;
      };
      processor : {
        id : UUID;
        displayId : String;
        name : String;
        emailId : String;
      };
      approvers : many {
        id : UUID;
        displayId : String;
        name : String;
        emailId : String;
      };
      serviceTeam : {
        id : UUID;
        displayId : String;
        name : String;
      };
      description : {
        noteId : UUID;
        content : String;
      };
      notes : many {
        noteId : UUID;
        id : UUID;
        content : String;
      };
      timePoints : {
        reportedOn : Timestamp;
        escalatedOn : Timestamp;
        completedOn : Timestamp;
        completionDueOn : Timestamp;
        assignedToCustomerOn : Timestamp;
        assignedToProcessorOn : Timestamp;
        initialReviewDueOn : Timestamp;
        initialReviewCompletedOn : Timestamp;
        resolutionDueOn : Timestamp;
        responseDueOn : Timestamp;
        closedOn : Timestamp;
      };
      categoryLevel1 : {
        id : UUID;
        displayId : String;
      };
      categoryLevel2 : {
        id : UUID;
        displayId : String;
      };
      extensions : { };
    }
  ) returns
    @title : 'Case patch response'
    {
      value : {
        id : UUID;
        displayId : String;
        subject : String;
        priority : String;
        priorityDescription : String;
        origin : String;
        caseType : String;
        caseTypeDescription : String;
        status : String;
        statusDescription : String;
        escalationStatus : String;
        registeredProducts : many {
          id : UUID;
          displayId : String;
          serialId : String;
        };
        functionalLocations : many {
          id : UUID;
          displayId : String;
        };
        productInstallPoints : many {
          id : UUID;
          displayId : String;
        };
        installedBases : many {
          id : UUID;
          displayId : String;
        };
        account : {
          id : UUID;
          displayId : String;
          name : String;
          country : String;
          state : String;
          streetPostalCode : String;
        };
        contact : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
          phoneNumber : String;
        };
        individualCustomer : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        processor : {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        approvers : many {
          id : UUID;
          displayId : String;
          name : String;
          emailId : String;
        };
        serviceTeam : {
          id : UUID;
          displayId : String;
          name : String;
        };
        description : {
          noteId : UUID;
          content : String;
        };
        notes : many {
          noteId : UUID;
          id : UUID;
          content : String;
        };
        relatedObjects : many {
          objectId : UUID;
          type : String;
          role : String;
        };
        timePoints : {
          reportedOn : Timestamp;
          escalatedOn : Timestamp;
          completedOn : Timestamp;
          completionDueOn : Timestamp;
          assignedToCustomerOn : Timestamp;
          assignedToProcessorOn : Timestamp;
          initialReviewDueOn : Timestamp;
          initialReviewCompletedOn : Timestamp;
          resolutionDueOn : Timestamp;
          responseDueOn : Timestamp;
          closedOn : Timestamp;
        };
        categoryLevel1 : {
          id : UUID;
          displayId : String;
        };
        categoryLevel2 : {
          id : UUID;
          displayId : String;
        };
        serviceLevelId : UUID;
        durationTerms : {
          durationWithAgent : Timestamp;
          durationWithCustomer : Timestamp;
        };
        isRead : Boolean;
        isEndOfPurpose : Boolean;
        isDepersonalized : Boolean;
        adminData : {
          createdBy : UUID;
          createdByName : String;
          createdOn : Timestamp;
          updatedBy : UUID;
          updatedByName : String;
          updatedOn : Timestamp;
        };
        extensions : { };
      };
      info : {
        code : String;
        details : many {
          message : String;
          target : String;
          code : String;
        };
        message : String;
        target : String;
      };
    };
};

