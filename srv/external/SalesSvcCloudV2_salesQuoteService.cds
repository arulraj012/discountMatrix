/* checksum : e9330dd758c2e1912282d9b2e97f0a09 */
namespace Sales.Quote;

@Capabilities.BatchSupported : false
@Capabilities.KeyAsSegmentSupported : true
@Core.Description : 'Sales Quote Service'
@Core.SchemaVersion : '1.0.0'
@Core.LongDescription : 'Create and manage sales quotes for accounts and individual customers. Using sales quotes, you can offer products to accounts and individual customers in accordance with specific terms and fixed conditions and convert them to sales orders'
service Service {
  @Common.Label : 'SalesQuote'
  @Core.Description : 'Query sales quotes.'
  @Core.LongDescription : 'Specify query parameters to return sales quotes.'
  @openapi.path : '/sap/c4c/api/v1/sales-quote-service/salesQuotes'
  function sap_c4c_api_v1_sales_quote_service_salesQuotes(
    @description : 'Show only the first n sales quotes.'
    @openapi.in : 'query'
    @openapi.name : '$top'
    _top : Integer,
    @description : 'Skip the first n sales quotes.'
    @openapi.in : 'query'
    @openapi.name : '$skip'
    _skip : Integer,
    @description : 'Search for a string within sales quote.'
    @openapi.in : 'query'
    @openapi.name : '$search'
    _search : String,
    @description : 'Order sales quotes by attribute.'
    @openapi.in : 'query'
    @openapi.name : '$orderby'
    _orderby : String,
    @description : 'Filter sales quotes by attribute.'
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
    @description : 'Indicates if count of sales quotes to be returned.'
    @openapi.in : 'query'
    @openapi.name : '$count'
    _count : Boolean,
    @description : 'Indicates the query to be used by sales quote service.'
    @openapi.in : 'query'
    @openapi.name : '$query'
    _query : String
  ) returns Service_types.SalesQuotequeryresponse;

  @Common.Label : 'SalesQuote'
  @Core.Description : 'Create a new sales quote.'
  @Core.LongDescription : 'Send sales quote information to create a sales quote entity.'
  @openapi.path : '/sap/c4c/api/v1/sales-quote-service/salesQuotes'
  action sap_c4c_api_v1_sales_quote_service_salesQuotes_post(
    @openapi.in : 'body'
    body : Service_types.SalesQuotecreaterequest
  ) returns Service_types.SalesQuotefile;

  @Common.Label : 'SalesQuote'
  @Core.Description : 'Retrieve a sales quote by ID.'
  @Core.LongDescription : 'Retrieve a sales quote using the sales quote ID.'
  @openapi.path : '/sap/c4c/api/v1/sales-quote-service/salesQuotes/{id}'
  function sap_c4c_api_v1_sales_quote_service_salesQuotes_(
    @description : 'Sales quote id.'
    @openapi.in : 'path'
    id : UUID
  ) returns Service_types.SalesQuotefile;

  @Common.Label : 'SalesQuote'
  @Core.Description : 'Update sales quote information.'
  @Core.LongDescription : 'Update a sales quote by ID.'
  @openapi.method : 'PATCH'
  @openapi.path : '/sap/c4c/api/v1/sales-quote-service/salesQuotes/{id}'
  action sap_c4c_api_v1_sales_quote_service_salesQuotes__patch(
    @description : 'Sales quote ID.'
    @openapi.in : 'path'
    id : UUID,
    @openapi.contentType : 'application/merge-patch+json'
    @openapi.in : 'body'
    body : Service_types.SalesQuotepatchupdaterequest
  ) returns Service_types.SalesQuotefile;

  @Common.Label : 'SalesQuote'
  @Core.Description : 'Delete a sales quote.'
  @Core.LongDescription : 'Delete a sales quote by ID.'
  @openapi.method : 'DELETE'
  @openapi.path : '/sap/c4c/api/v1/sales-quote-service/salesQuotes/{id}'
  action sap_c4c_api_v1_sales_quote_service_salesQuotes__delete(
    @description : 'Sales quote id'
    @openapi.in : 'path'
    id : UUID
  );
};

type Service_types.error {
  error : {
    code : String;
    details : many {
      message : String;
      code : String;
      target : String;
    };
    message : String;
    target : String;
  };
};

@title : 'Sales Quote query response'
type Service_types.SalesQuotequeryresponse {
  count : Integer;
  value : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'ID'
    displayId : String(35);
    isPrimary : Boolean;
    @title : 'Customer Reference'
    customerReferenceId : String;
    @title : 'Language Code'
    documentLanguage : String;
    @title : 'Language'
    documentLanguageDescription : String;
    documentDate : Date;
    @title : 'Description'
    name : String;
    @title : 'Document Type Code'
    documentType : String;
    @title : 'Document Type'
    documentTypeDescription : String;
    validityPeriod : {
      startDate : Date;
      endDate : Date;
    };
    requestedFulfillmentPeriod : {
      startDateTime : Timestamp;
      endDateTime : Timestamp;
    };
    account : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Account ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Account'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
      @title : 'Technical ID'
      topAccountId : UUID;
      @title : 'Top Account ID'
      topAccountDisplayId : String;
      @title : 'Top Account'
      topAccountName : String;
      @title : 'Technical ID'
      parentAccountId : UUID;
      @title : 'Parent Account ID'
      parentAccountDisplayId : String;
      @title : 'Parent Account'
      parentAccountName : String;
    };
    individualCustomer : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Individual Customer ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Individual Customer'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    shipTo : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Ship-To ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Ship-To'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    shipToIndividualCustomer : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Ship-To Individual Customer ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Ship-To Individual Customer'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    billTo : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Bill-To ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Bill-To'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    billToIndividualCustomer : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Bill-To Individual Customer ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Bill-To Individual Customer'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    owner : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Owner ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Owner Name'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    contactOfAccount : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Contact ID of Account'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Contact of Account'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    salesEmployee : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Sales Employee ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Sales Employee'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    salesUnit : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Sales Unit ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Sales Unit'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    businessTerms : {
      @title : 'Delivery Priority Code'
      deliveryPriority : String;
      @title : 'Delivery Priority'
      deliveryPriorityDescription : String;
      @title : 'Currency Code'
      currency : String;
      @title : 'Currency'
      currencyDescription : String;
      priceDate : Date;
      probabilityPercent : Double;
      @title : 'Payment Terms Code'
      cashDiscountTerms : String;
      @title : 'Payment Terms'
      cashDiscountTermsDescription : String;
      incoterms : {
        @title : 'Incoterms Code'
        classification : String;
        @title : 'Incoterms'
        classificationDescription : String;
        @title : 'Incoterms Location'
        location : String;
      };
      @title : 'Customer Group Code'
      customerGroup : String;
      @title : 'Customer Group'
      customerGroupDescription : String;
    };
    @title : 'Status'
    @assert.range : true
    lifeCycleStatus : String enum {
      OPEN;
      IN_PROCESS;
      COMPLETED;
      INACTIVE_VERSION;
    };
    @title : 'Consistency'
    @assert.range : true
    consistencyStatus : String enum {
      INCONSISTENT;
      CONSISTENT;
    };
    lastConsistencyCheckedOn : Timestamp;
    @title : 'Credit Status'
    @assert.range : true
    creditWorthinessStatus : String enum {
      NOT_RELEVANT;
      CHECK_PENDING;
      LIMIT_NOT_EXCEEDED;
      LIMIT_EXCEEDED;
      MANUALLY;
    };
    @title : 'Approval Status'
    @assert.range : true
    approvalStatus : String enum {
      NOT_STARTED;
      APPROVAL_NOT_NECESSARY;
      IN_APPROVAL;
      APPROVED;
      REJECTED;
      WITHDRAWN;
    };
    @title : 'ATP Status'
    @assert.range : true
    availabilityStatus : String enum {
      CONFIRMATION_PENDING;
      NOT_CONFIRMED;
      CONFIRMED_INSUFFICIENTLY;
      CONFIRMED_SUFFICIENTLY;
    };
    @title : 'Progress'
    @assert.range : true
    progressStatus : String enum {
      OPEN;
      IN_PROCESS;
      PENDING;
      WON;
      LOST;
      STOPPED;
    };
    @title : 'Code: Reason for Progress'
    progressStatusReason : String;
    @title : 'Reason for Progress'
    progressStatusReasonDescription : String;
    parties : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Party Technical ID'
      partyId : UUID;
      @title : 'Party ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Name'
      partyName : String;
      isMain : Boolean;
      @title : 'Role Category'
      roleCategory : String;
      @title : 'Party Role'
      role : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String(255);
      @title : 'Email'
      email : String(255);
      @title : 'Phone'
      phoneFormattedNumber : String(40);
      @title : 'Mobile'
      mobileFormattedNumber : String(40);
      @title : 'Address ID'
      addressId : UUID;
      @title : 'House Number'
      houseId : String(10);
      @title : 'Country/Region'
      country : String;
      @title : 'Street'
      street : String(60);
      @title : 'City'
      city : String(40);
      @title : 'Postal Code'
      postalCode : String(10);
      region : {
        @title : 'Country/Region'
        country : String;
        @title : 'Region'
        region : String;
      };
      @title : 'Top Account ID'
      topAccountId : String;
      @title : 'Top Account'
      topAccountName : String;
      @title : 'Top Account ID'
      topAccountDisplayId : String;
      @title : 'Parent Account ID'
      parentAccountId : String;
      @title : 'Parent Account'
      parentAccountName : String;
      @title : 'Parent Account ID'
      parentAccountDisplayId : String;
      isInternal : Boolean;
    };
    salesTerritories : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Territory Technical ID'
      salesTerritoryId : UUID;
      @title : 'Territory ID'
      salesTerritoryDisplayId : String;
      @title : 'Territory'
      salesTerritoryName : String;
      isMain : Boolean;
      @title : 'Territory Determination Method Code'
      salesTerritoryDeterminationMethod : String;
      @title : 'Territory Determination Method'
      salesTerritoryDeterminationMethodDescription : String;
    };
    businessArea : {
      @title : 'Sales Organization Technical ID'
      salesOrganisationId : UUID;
      @title : 'Sales Organization ID'
      salesOrganisationDisplayId : String;
      @title : 'Sales Organization'
      salesOrganisationName : String;
      @title : 'Sales Organization Determination Method Code'
      salesOrganisationDeterminationMethod : String;
      @title : 'Sales Organization Determination Method'
      salesOrganisationDeterminationMethodDescription : String;
      @title : 'Sales Group Technical ID'
      salesGroupId : UUID;
      @title : 'Sales Group ID'
      salesGroupDisplayId : String;
      @title : 'Sales Group'
      salesGroupName : String;
      @title : 'Sales Group Determination Method Code'
      salesGroupDeterminationMethod : String;
      @title : 'Sales Group Determination Method'
      salesGroupDeterminationMethodDescription : String;
      @title : 'Sales Office Technical ID'
      salesOfficeId : UUID;
      @title : 'Sales Office ID'
      salesOfficeDisplayId : String;
      @title : 'Sales Office'
      salesOfficeName : String;
      @title : 'Sales Office Determination Method Code'
      salesOfficeDeterminationMethod : String;
      @title : 'Sales Office Determination Method'
      salesOfficeDeterminationMethodDescription : String;
      @title : 'Territory Technical ID'
      salesTerritoryId : UUID;
      @title : 'Territory ID'
      salesTerritoryDisplayId : String;
      @title : 'Territory'
      salesTerritoryName : String;
      @title : 'Territory Determination Method Code'
      salesTerritoryDeterminationMethod : String;
      @title : 'Territory Determination Method'
      salesTerritoryDeterminationMethodDescription : String;
      @title : 'Distribution Channel Code'
      distributionChannel : String;
      @title : 'Distribution Channel'
      distributionChannelDescription : String;
      @title : 'Distribution Channel Determination Method Code'
      distributionChannelDeterminationMethod : String;
      @title : 'Distribution Channel Determination Method'
      distributionChannelDeterminationMethodDescription : String;
      @title : 'Division Code'
      division : String;
      @title : 'Division'
      divisionDescription : String;
      @title : 'Division Determination Method Code'
      divisionDeterminationMethod : String;
      @title : 'Division Determination Method'
      divisionDeterminationMethodDescription : String;
    };
    notes : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Note Type'
      type : String;
      @title : 'Note'
      content : String;
      adminData : {
        @title : 'Created By (Technical ID)'
        createdBy : UUID;
        @title : 'Created By'
        createdByName : String;
        createdOn : Timestamp;
        @title : 'Changed By (Technical ID)'
        updatedBy : UUID;
        @title : 'Changed By'
        updatedByName : String;
        updatedOn : Timestamp;
      };
    };
    attachments : many {
      @title : 'ID'
      id : UUID;
      @title : 'Title'
      title : String;
      @title : 'Category'
      category : String;
      @title : 'File Name'
      fileName : String;
      @title : 'File Size'
      fileSize : String;
      @title : 'Content Type'
      contentType : String;
      @title : 'URL'
      url : String;
      adminData : {
        @title : 'Created By (Technical ID)'
        createdBy : UUID;
        @title : 'Created By'
        createdByName : String;
        createdOn : Timestamp;
        @title : 'Changed By (Technical ID)'
        updatedBy : UUID;
        @title : 'Changed By'
        updatedByName : String;
        updatedOn : Timestamp;
      };
    };
    items : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'ID'
      displayId : String(10);
      @title : 'Description'
      description : String;
      @title : 'Item Type'
      itemType : String;
      @title : 'Item Type'
      itemTypeDescription : String;
      @title : 'Type Code'
      @assert.range : true
      typeCode : String enum {
        PRODUCT;
        TEXT;
      };
      @title : 'Technical ID'
      parentItemId : UUID;
      @title : 'Parent ID'
      parentItemDisplayId : String(10);
      @title : 'ATP Status'
      @assert.range : true
      availabilityStatus : String enum {
        CONFIRMATION_PENDING;
        NOT_CONFIRMED;
        CONFIRMED_INSUFFICIENTLY;
        CONFIRMED_SUFFICIENTLY;
      };
      @title : 'Progress'
      @assert.range : true
      progressStatus : String enum {
        OPEN;
        IN_PROCESS;
        PENDING;
        WON;
        LOST;
        STOPPED;
      };
      @title : 'Reason for Progress Code'
      progressStatusReason : String;
      @title : 'Reason for Progress'
      progressStatusReasonDescription : String;
      productData : {
        @title : 'Product Technical ID'
        productId : UUID;
        @title : 'Product ID'
        productDisplayId : String;
        @title : 'Original Product Technical ID'
        originalProductId : UUID;
        @title : 'Original Product ID'
        originalProductDisplayId : String;
        @title : 'Product Category Technical ID'
        productCategoryId : UUID;
        @title : 'Product Category ID'
        productCategoryDisplayId : String;
        @title : 'Unit Code'
        productQuantityMeasureUnit : String;
        @title : 'Unit'
        productQuantityMeasureUnitDescription : String;
      };
      @title : 'Product List Technical ID'
      productListId : UUID;
      @title : 'Product List'
      productListDisplayId : String;
      attachments : many {
        @title : 'Technical ID'
        id : UUID;
        @title : 'lbl_salesQuoteAttachment_attachmentType'
        type : String;
        @title : 'lbl_salesQuoteAttachment_textContent'
        content : String;
        adminData : {
          @title : 'Created By (Technical ID)'
          createdBy : UUID;
          @title : 'Created By'
          createdByName : String;
          createdOn : Timestamp;
          @title : 'Changed By (Technical ID)'
          updatedBy : UUID;
          @title : 'Changed By'
          updatedByName : String;
          updatedOn : Timestamp;
        };
      };
      scheduleLines : many {
        @title : 'Technical ID'
        id : UUID;
        @title : 'ID'
        displayId : String(4);
        quantity : {
          content : Double;
          @title : 'Unit'
          uomCode : String;
        };
        confirmedQuantity : {
          content : Double;
          @title : 'Unit'
          uomCode : String;
        };
        originalQuantity : {
          content : Double;
          @title : 'Unit'
          uomCode : String;
        };
        period : {
          startDateTime : Timestamp;
          endDateTime : Timestamp;
        };
      };
      notes : many {
        @title : 'Technical ID'
        id : UUID;
        @title : 'Note Type'
        type : String;
        @title : 'Note'
        content : String;
        adminData : {
          @title : 'Created By (Technical ID)'
          createdBy : UUID;
          @title : 'Created By'
          createdByName : String;
          createdOn : Timestamp;
          @title : 'Changed By (Technical ID)'
          updatedBy : UUID;
          @title : 'Changed By'
          updatedByName : String;
          updatedOn : Timestamp;
        };
      };
      @title : 'Usage Type'
      @assert.range : true
      usageType : String enum {
        PRODUCT_SUBSTITUTION;
        BILL_OF_MATERIAL;
        FREE_GOOD;
        CROSS_SELL;
        UP_SELL;
        DOWN_SELL;
        NONE;
      };
      totalValues : {
        netAmount : {
          content : Double;
          @title : 'Currency'
          currencyCode : String;
        };
        grossAmount : {
          content : Double;
          @title : 'Currency'
          currencyCode : String;
        };
        taxAmount : {
          content : Double;
          @title : 'Currency'
          currencyCode : String;
        };
        requestedQuantity : {
          content : Double;
          @title : 'Unit'
          uomCode : String;
        };
        confirmedQuantity : {
          content : Double;
          @title : 'Unit'
          uomCode : String;
        };
        netPrice : {
          amount : {
            content : Double;
            @title : 'Currency'
            currencyCode : String;
          };
          baseQuantity : {
            content : Double;
            @title : 'Unit'
            uomCode : String;
          };
        };
      };
      adminData : {
        @title : 'Created By (Technical ID)'
        createdBy : UUID;
        @title : 'Created By'
        createdByName : String;
        createdOn : Timestamp;
        @title : 'Changed By (Technical ID)'
        updatedBy : UUID;
        @title : 'Changed By'
        updatedByName : String;
        updatedOn : Timestamp;
      };
      businessTerms : {
        @title : 'Delivery Priority Code'
        deliveryPriority : String;
        @title : 'Delivery Priority'
        deliveryPriorityDescription : String;
        @title : 'Currency Code'
        currency : String;
        @title : 'Currency'
        currencyDescription : String;
        priceDate : Date;
        probabilityPercent : Double;
        @title : 'Payment Terms Code'
        cashDiscountTerms : String;
        @title : 'Payment Terms'
        cashDiscountTermsDescription : String;
        @title : 'Customer Group Code'
        customerGroup : String;
        @title : 'Customer Group'
        customerGroupDescription : String;
        incoterms : {
          @title : 'Incoterms Code'
          classification : String;
          @title : 'Incoterms'
          classificationDescription : String;
          @title : 'Incoterms Location'
          location : String;
        };
      };
      priceElements : many {
        @title : 'Price Element ID'
        id : UUID;
        @title : 'Price Element Description'
        description : String;
        stepNumber : Decimal;
        counter : Decimal;
        @title : 'Price Element Condition Type'
        conditionType : String;
        @title : 'Price Element Category Code'
        categoryCode : String;
        @title : 'Price Element Origin Code'
        originCode : String;
        calculatedAmount : {
          content : Double;
          @title : 'Price Element Net Currency'
          currencyCode : String;
        };
        rateAmount : {
          content : Double;
          @title : 'Price Element Net Price Currency'
          currencyCode : String;
        };
        rateBaseQuantity : {
          content : Double;
          @title : 'Price Element Unit of Measure'
          uomCode : String;
        };
        isManuallyChanged : Boolean;
        isDeleteEnabled : Boolean;
        @title : 'Reason Code for Inactive Price Element'
        inactiveReasonCode : String;
        isEffective : Boolean;
      };
      @title : 'Customer Part Number'
      customerPartNumber : String;
      @title : 'GTIN'
      gtin : String;
      referenceUsages : { };
      extensions : { };
    };
    relatedObjects : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Related Entity Technical ID'
      objectId : String;
      @title : 'Related Entity ID'
      displayId : String;
      @title : 'Related Entity Type'
      type : String;
      @title : 'Related Entity Role'
      role : String;
      @title : 'Communication System ID'
      communicationSystemId : String;
      @title : 'Communication System'
      communicationSystemDisplayId : String;
    };
    externalId : {
      @title : 'Technical ID'
      id : UUID;
      @title : 'External ID'
      displayId : String;
      @title : 'Communication System'
      communicationSystemDisplayId : String;
      @title : 'Communication System ID'
      communicationSystemId : UUID;
    };
    adminData : {
      @title : 'Created By (Technical ID)'
      createdBy : UUID;
      @title : 'Created By'
      createdByName : String;
      createdOn : Timestamp;
      @title : 'Changed By (Technical ID)'
      updatedBy : UUID;
      @title : 'Changed By'
      updatedByName : String;
      updatedOn : Timestamp;
    };
    totalValues : {
      netAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      taxAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      grossAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
    };
    creditWorthiness : {
      creditLimitAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      creditExposureAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      creditExceededAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
    };
    @title : 'Pricing Status'
    @assert.range : true
    pricingStatus : String enum {
      NOT_CALCULATED;
      CALCULATED_SUCCESSFULLY;
      CALCULATED_WITH_ERRORS;
      RECALCULATION_NEEDED;
      ESTIMATED_SUCCESSFULLY;
      ESTIMATED_WITH_ERRORS;
    };
    @title : 'Pricing Procedure'
    pricingProcedureName : String;
    pricingProcedureIsExternal : Boolean;
    priceElements : many {
      @title : 'Price Element ID'
      id : UUID;
      @title : 'Price Element Description'
      description : String;
      stepNumber : Decimal;
      counter : Decimal;
      @title : 'Price Element Condition Type'
      conditionType : String;
      @title : 'Price Element Category Code'
      categoryCode : String;
      @title : 'Price Element Origin Code'
      originCode : String;
      calculatedAmount : {
        content : Double;
        @title : 'Price Element Net Currency'
        currencyCode : String;
      };
      rateAmount : {
        content : Double;
        @title : 'Price Element Net Price Currency'
        currencyCode : String;
      };
      rateBaseQuantity : {
        content : Double;
        @title : 'Price Element Unit of Measure'
        uomCode : String;
      };
      isManuallyChanged : Boolean;
      isDeleteEnabled : Boolean;
      @title : 'Reason Code for Inactive Price Element'
      inactiveReasonCode : String;
      isEffective : Boolean;
    };
    @title : 'External Order Request Status'
    @assert.range : true
    externalSalesOrderRequestStatus : String enum {
      NOT_STARTED;
      IN_PROCESS;
      FINISHED;
      INTERRUPTED;
    };
    @title : 'Transfer Status'
    @assert.range : true
    transferStatus : String enum {
      NOT_STARTED;
      IN_PROCESS;
      FINISHED;
      INTERRUPTED;
    };
    campaign : {
      @title : 'Campaign Technical ID'
      id : UUID;
      @title : 'Campaign ID'
      displayId : String;
      @title : 'Campaign'
      description : String;
    };
    referenceUsages : { };
    extensions : { };
  };
};

@title : 'Sales Quote file'
type Service_types.SalesQuotefile {
  value : {
    @title : 'Technical ID'
    id : UUID;
    @title : 'ID'
    displayId : String(35);
    isPrimary : Boolean;
    @title : 'Customer Reference'
    customerReferenceId : String;
    @title : 'Language Code'
    documentLanguage : String;
    @title : 'Language'
    documentLanguageDescription : String;
    documentDate : Date;
    @title : 'Description'
    name : String;
    @title : 'Document Type Code'
    documentType : String;
    @title : 'Document Type'
    documentTypeDescription : String;
    validityPeriod : {
      startDate : Date;
      endDate : Date;
    };
    requestedFulfillmentPeriod : {
      startDateTime : Timestamp;
      endDateTime : Timestamp;
    };
    account : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Account ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Account'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
      @title : 'Technical ID'
      topAccountId : UUID;
      @title : 'Top Account ID'
      topAccountDisplayId : String;
      @title : 'Top Account'
      topAccountName : String;
      @title : 'Technical ID'
      parentAccountId : UUID;
      @title : 'Parent Account ID'
      parentAccountDisplayId : String;
      @title : 'Parent Account'
      parentAccountName : String;
    };
    individualCustomer : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Individual Customer ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Individual Customer'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    shipTo : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Ship-To ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Ship-To'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    shipToIndividualCustomer : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Ship-To Individual Customer ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Ship-To Individual Customer'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    billTo : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Bill-To ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Bill-To'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    billToIndividualCustomer : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Bill-To Individual Customer ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Bill-To Individual Customer'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    owner : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Owner ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Owner Name'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    contactOfAccount : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Contact ID of Account'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Contact of Account'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    salesEmployee : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Sales Employee ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Sales Employee'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    salesUnit : {
      @title : 'Technical ID'
      partyId : UUID;
      @title : 'Sales Unit ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Sales Unit'
      partyName : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String;
      @title : 'Email'
      email : String;
      @title : 'Phone'
      phoneFormattedNumber : String;
      @title : 'Mobile'
      mobileFormattedNumber : String;
    };
    businessTerms : {
      @title : 'Delivery Priority Code'
      deliveryPriority : String;
      @title : 'Delivery Priority'
      deliveryPriorityDescription : String;
      @title : 'Currency Code'
      currency : String;
      @title : 'Currency'
      currencyDescription : String;
      priceDate : Date;
      probabilityPercent : Double;
      @title : 'Payment Terms Code'
      cashDiscountTerms : String;
      @title : 'Payment Terms'
      cashDiscountTermsDescription : String;
      incoterms : {
        @title : 'Incoterms Code'
        classification : String;
        @title : 'Incoterms'
        classificationDescription : String;
        @title : 'Incoterms Location'
        location : String;
      };
      @title : 'Customer Group Code'
      customerGroup : String;
      @title : 'Customer Group'
      customerGroupDescription : String;
    };
    @title : 'Status'
    @assert.range : true
    lifeCycleStatus : String enum {
      OPEN;
      IN_PROCESS;
      COMPLETED;
      INACTIVE_VERSION;
    };
    @title : 'Consistency'
    @assert.range : true
    consistencyStatus : String enum {
      INCONSISTENT;
      CONSISTENT;
    };
    lastConsistencyCheckedOn : Timestamp;
    @title : 'Credit Status'
    @assert.range : true
    creditWorthinessStatus : String enum {
      NOT_RELEVANT;
      CHECK_PENDING;
      LIMIT_NOT_EXCEEDED;
      LIMIT_EXCEEDED;
      MANUALLY;
    };
    @title : 'Approval Status'
    @assert.range : true
    approvalStatus : String enum {
      NOT_STARTED;
      APPROVAL_NOT_NECESSARY;
      IN_APPROVAL;
      APPROVED;
      REJECTED;
      WITHDRAWN;
    };
    @title : 'ATP Status'
    @assert.range : true
    availabilityStatus : String enum {
      CONFIRMATION_PENDING;
      NOT_CONFIRMED;
      CONFIRMED_INSUFFICIENTLY;
      CONFIRMED_SUFFICIENTLY;
    };
    @title : 'Progress'
    @assert.range : true
    progressStatus : String enum {
      OPEN;
      IN_PROCESS;
      PENDING;
      WON;
      LOST;
      STOPPED;
    };
    @title : 'Code: Reason for Progress'
    progressStatusReason : String;
    @title : 'Reason for Progress'
    progressStatusReasonDescription : String;
    parties : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Party Technical ID'
      partyId : UUID;
      @title : 'Party ID'
      partyDisplayId : String;
      @title : 'Type'
      type : String;
      @title : 'Name'
      partyName : String;
      isMain : Boolean;
      @title : 'Role Category'
      roleCategory : String;
      @title : 'Party Role'
      role : String;
      @title : 'Determination Method Code'
      determinationMethod : String;
      @title : 'Determination Method'
      determinationMethodDescription : String;
      @title : 'Address'
      formattedPostalAddress : String(255);
      @title : 'Email'
      email : String(255);
      @title : 'Phone'
      phoneFormattedNumber : String(40);
      @title : 'Mobile'
      mobileFormattedNumber : String(40);
      @title : 'Address ID'
      addressId : UUID;
      @title : 'House Number'
      houseId : String(10);
      @title : 'Country/Region'
      country : String;
      @title : 'Street'
      street : String(60);
      @title : 'City'
      city : String(40);
      @title : 'Postal Code'
      postalCode : String(10);
      region : {
        @title : 'Country/Region'
        country : String;
        @title : 'Region'
        region : String;
      };
      @title : 'Top Account ID'
      topAccountId : String;
      @title : 'Top Account'
      topAccountName : String;
      @title : 'Top Account ID'
      topAccountDisplayId : String;
      @title : 'Parent Account ID'
      parentAccountId : String;
      @title : 'Parent Account'
      parentAccountName : String;
      @title : 'Parent Account ID'
      parentAccountDisplayId : String;
      isInternal : Boolean;
    };
    salesTerritories : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Territory Technical ID'
      salesTerritoryId : UUID;
      @title : 'Territory ID'
      salesTerritoryDisplayId : String;
      @title : 'Territory'
      salesTerritoryName : String;
      isMain : Boolean;
      @title : 'Territory Determination Method Code'
      salesTerritoryDeterminationMethod : String;
      @title : 'Territory Determination Method'
      salesTerritoryDeterminationMethodDescription : String;
    };
    businessArea : {
      @title : 'Sales Organization Technical ID'
      salesOrganisationId : UUID;
      @title : 'Sales Organization ID'
      salesOrganisationDisplayId : String;
      @title : 'Sales Organization'
      salesOrganisationName : String;
      @title : 'Sales Organization Determination Method Code'
      salesOrganisationDeterminationMethod : String;
      @title : 'Sales Organization Determination Method'
      salesOrganisationDeterminationMethodDescription : String;
      @title : 'Sales Group Technical ID'
      salesGroupId : UUID;
      @title : 'Sales Group ID'
      salesGroupDisplayId : String;
      @title : 'Sales Group'
      salesGroupName : String;
      @title : 'Sales Group Determination Method Code'
      salesGroupDeterminationMethod : String;
      @title : 'Sales Group Determination Method'
      salesGroupDeterminationMethodDescription : String;
      @title : 'Sales Office Technical ID'
      salesOfficeId : UUID;
      @title : 'Sales Office ID'
      salesOfficeDisplayId : String;
      @title : 'Sales Office'
      salesOfficeName : String;
      @title : 'Sales Office Determination Method Code'
      salesOfficeDeterminationMethod : String;
      @title : 'Sales Office Determination Method'
      salesOfficeDeterminationMethodDescription : String;
      @title : 'Territory Technical ID'
      salesTerritoryId : UUID;
      @title : 'Territory ID'
      salesTerritoryDisplayId : String;
      @title : 'Territory'
      salesTerritoryName : String;
      @title : 'Territory Determination Method Code'
      salesTerritoryDeterminationMethod : String;
      @title : 'Territory Determination Method'
      salesTerritoryDeterminationMethodDescription : String;
      @title : 'Distribution Channel Code'
      distributionChannel : String;
      @title : 'Distribution Channel'
      distributionChannelDescription : String;
      @title : 'Distribution Channel Determination Method Code'
      distributionChannelDeterminationMethod : String;
      @title : 'Distribution Channel Determination Method'
      distributionChannelDeterminationMethodDescription : String;
      @title : 'Division Code'
      division : String;
      @title : 'Division'
      divisionDescription : String;
      @title : 'Division Determination Method Code'
      divisionDeterminationMethod : String;
      @title : 'Division Determination Method'
      divisionDeterminationMethodDescription : String;
    };
    notes : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Note Type'
      type : String;
      @title : 'Note'
      content : String;
      adminData : {
        @title : 'Created By (Technical ID)'
        createdBy : UUID;
        @title : 'Created By'
        createdByName : String;
        createdOn : Timestamp;
        @title : 'Changed By (Technical ID)'
        updatedBy : UUID;
        @title : 'Changed By'
        updatedByName : String;
        updatedOn : Timestamp;
      };
    };
    attachments : many {
      @title : 'ID'
      id : UUID;
      @title : 'Title'
      title : String;
      @title : 'Category'
      category : String;
      @title : 'File Name'
      fileName : String;
      @title : 'File Size'
      fileSize : String;
      @title : 'Content Type'
      contentType : String;
      @title : 'URL'
      url : String;
      adminData : {
        @title : 'Created By (Technical ID)'
        createdBy : UUID;
        @title : 'Created By'
        createdByName : String;
        createdOn : Timestamp;
        @title : 'Changed By (Technical ID)'
        updatedBy : UUID;
        @title : 'Changed By'
        updatedByName : String;
        updatedOn : Timestamp;
      };
    };
    items : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'ID'
      displayId : String(10);
      @title : 'Description'
      description : String;
      @title : 'Item Type'
      itemType : String;
      @title : 'Item Type'
      itemTypeDescription : String;
      @title : 'Type Code'
      @assert.range : true
      typeCode : String enum {
        PRODUCT;
        TEXT;
      };
      @title : 'Technical ID'
      parentItemId : UUID;
      @title : 'Parent ID'
      parentItemDisplayId : String(10);
      @title : 'ATP Status'
      @assert.range : true
      availabilityStatus : String enum {
        CONFIRMATION_PENDING;
        NOT_CONFIRMED;
        CONFIRMED_INSUFFICIENTLY;
        CONFIRMED_SUFFICIENTLY;
      };
      @title : 'Progress'
      @assert.range : true
      progressStatus : String enum {
        OPEN;
        IN_PROCESS;
        PENDING;
        WON;
        LOST;
        STOPPED;
      };
      @title : 'Reason for Progress Code'
      progressStatusReason : String;
      @title : 'Reason for Progress'
      progressStatusReasonDescription : String;
      productData : {
        @title : 'Product Technical ID'
        productId : UUID;
        @title : 'Product ID'
        productDisplayId : String;
        @title : 'Original Product Technical ID'
        originalProductId : UUID;
        @title : 'Original Product ID'
        originalProductDisplayId : String;
        @title : 'Product Category Technical ID'
        productCategoryId : UUID;
        @title : 'Product Category ID'
        productCategoryDisplayId : String;
        @title : 'Unit Code'
        productQuantityMeasureUnit : String;
        @title : 'Unit'
        productQuantityMeasureUnitDescription : String;
      };
      @title : 'Product List Technical ID'
      productListId : UUID;
      @title : 'Product List'
      productListDisplayId : String;
      attachments : many {
        @title : 'Technical ID'
        id : UUID;
        @title : 'lbl_salesQuoteAttachment_attachmentType'
        type : String;
        @title : 'lbl_salesQuoteAttachment_textContent'
        content : String;
        adminData : {
          @title : 'Created By (Technical ID)'
          createdBy : UUID;
          @title : 'Created By'
          createdByName : String;
          createdOn : Timestamp;
          @title : 'Changed By (Technical ID)'
          updatedBy : UUID;
          @title : 'Changed By'
          updatedByName : String;
          updatedOn : Timestamp;
        };
      };
      scheduleLines : many {
        @title : 'Technical ID'
        id : UUID;
        @title : 'ID'
        displayId : String(4);
        quantity : {
          content : Double;
          @title : 'Unit'
          uomCode : String;
        };
        confirmedQuantity : {
          content : Double;
          @title : 'Unit'
          uomCode : String;
        };
        originalQuantity : {
          content : Double;
          @title : 'Unit'
          uomCode : String;
        };
        period : {
          startDateTime : Timestamp;
          endDateTime : Timestamp;
        };
      };
      notes : many {
        @title : 'Technical ID'
        id : UUID;
        @title : 'Note Type'
        type : String;
        @title : 'Note'
        content : String;
        adminData : {
          @title : 'Created By (Technical ID)'
          createdBy : UUID;
          @title : 'Created By'
          createdByName : String;
          createdOn : Timestamp;
          @title : 'Changed By (Technical ID)'
          updatedBy : UUID;
          @title : 'Changed By'
          updatedByName : String;
          updatedOn : Timestamp;
        };
      };
      @title : 'Usage Type'
      @assert.range : true
      usageType : String enum {
        PRODUCT_SUBSTITUTION;
        BILL_OF_MATERIAL;
        FREE_GOOD;
        CROSS_SELL;
        UP_SELL;
        DOWN_SELL;
        NONE;
      };
      totalValues : {
        netAmount : {
          content : Double;
          @title : 'Currency'
          currencyCode : String;
        };
        grossAmount : {
          content : Double;
          @title : 'Currency'
          currencyCode : String;
        };
        taxAmount : {
          content : Double;
          @title : 'Currency'
          currencyCode : String;
        };
        requestedQuantity : {
          content : Double;
          @title : 'Unit'
          uomCode : String;
        };
        confirmedQuantity : {
          content : Double;
          @title : 'Unit'
          uomCode : String;
        };
        netPrice : {
          amount : {
            content : Double;
            @title : 'Currency'
            currencyCode : String;
          };
          baseQuantity : {
            content : Double;
            @title : 'Unit'
            uomCode : String;
          };
        };
      };
      adminData : {
        @title : 'Created By (Technical ID)'
        createdBy : UUID;
        @title : 'Created By'
        createdByName : String;
        createdOn : Timestamp;
        @title : 'Changed By (Technical ID)'
        updatedBy : UUID;
        @title : 'Changed By'
        updatedByName : String;
        updatedOn : Timestamp;
      };
      businessTerms : {
        @title : 'Delivery Priority Code'
        deliveryPriority : String;
        @title : 'Delivery Priority'
        deliveryPriorityDescription : String;
        @title : 'Currency Code'
        currency : String;
        @title : 'Currency'
        currencyDescription : String;
        priceDate : Date;
        probabilityPercent : Double;
        @title : 'Payment Terms Code'
        cashDiscountTerms : String;
        @title : 'Payment Terms'
        cashDiscountTermsDescription : String;
        @title : 'Customer Group Code'
        customerGroup : String;
        @title : 'Customer Group'
        customerGroupDescription : String;
        incoterms : {
          @title : 'Incoterms Code'
          classification : String;
          @title : 'Incoterms'
          classificationDescription : String;
          @title : 'Incoterms Location'
          location : String;
        };
      };
      priceElements : many {
        @title : 'Price Element ID'
        id : UUID;
        @title : 'Price Element Description'
        description : String;
        stepNumber : Decimal;
        counter : Decimal;
        @title : 'Price Element Condition Type'
        conditionType : String;
        @title : 'Price Element Category Code'
        categoryCode : String;
        @title : 'Price Element Origin Code'
        originCode : String;
        calculatedAmount : {
          content : Double;
          @title : 'Price Element Net Currency'
          currencyCode : String;
        };
        rateAmount : {
          content : Double;
          @title : 'Price Element Net Price Currency'
          currencyCode : String;
        };
        rateBaseQuantity : {
          content : Double;
          @title : 'Price Element Unit of Measure'
          uomCode : String;
        };
        isManuallyChanged : Boolean;
        isDeleteEnabled : Boolean;
        @title : 'Reason Code for Inactive Price Element'
        inactiveReasonCode : String;
        isEffective : Boolean;
      };
      @title : 'Customer Part Number'
      customerPartNumber : String;
      @title : 'GTIN'
      gtin : String;
      referenceUsages : { };
      extensions : { };
    };
    relatedObjects : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Related Entity Technical ID'
      objectId : String;
      @title : 'Related Entity ID'
      displayId : String;
      @title : 'Related Entity Type'
      type : String;
      @title : 'Related Entity Role'
      role : String;
      @title : 'Communication System ID'
      communicationSystemId : String;
      @title : 'Communication System'
      communicationSystemDisplayId : String;
    };
    externalId : {
      @title : 'Technical ID'
      id : UUID;
      @title : 'External ID'
      displayId : String;
      @title : 'Communication System'
      communicationSystemDisplayId : String;
      @title : 'Communication System ID'
      communicationSystemId : UUID;
    };
    adminData : {
      @title : 'Created By (Technical ID)'
      createdBy : UUID;
      @title : 'Created By'
      createdByName : String;
      createdOn : Timestamp;
      @title : 'Changed By (Technical ID)'
      updatedBy : UUID;
      @title : 'Changed By'
      updatedByName : String;
      updatedOn : Timestamp;
    };
    totalValues : {
      netAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      taxAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      grossAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
    };
    creditWorthiness : {
      creditLimitAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      creditExposureAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      creditExceededAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
    };
    @title : 'Pricing Status'
    @assert.range : true
    pricingStatus : String enum {
      NOT_CALCULATED;
      CALCULATED_SUCCESSFULLY;
      CALCULATED_WITH_ERRORS;
      RECALCULATION_NEEDED;
      ESTIMATED_SUCCESSFULLY;
      ESTIMATED_WITH_ERRORS;
    };
    @title : 'Pricing Procedure'
    pricingProcedureName : String;
    pricingProcedureIsExternal : Boolean;
    priceElements : many {
      @title : 'Price Element ID'
      id : UUID;
      @title : 'Price Element Description'
      description : String;
      stepNumber : Decimal;
      counter : Decimal;
      @title : 'Price Element Condition Type'
      conditionType : String;
      @title : 'Price Element Category Code'
      categoryCode : String;
      @title : 'Price Element Origin Code'
      originCode : String;
      calculatedAmount : {
        content : Double;
        @title : 'Price Element Net Currency'
        currencyCode : String;
      };
      rateAmount : {
        content : Double;
        @title : 'Price Element Net Price Currency'
        currencyCode : String;
      };
      rateBaseQuantity : {
        content : Double;
        @title : 'Price Element Unit of Measure'
        uomCode : String;
      };
      isManuallyChanged : Boolean;
      isDeleteEnabled : Boolean;
      @title : 'Reason Code for Inactive Price Element'
      inactiveReasonCode : String;
      isEffective : Boolean;
    };
    @title : 'External Order Request Status'
    @assert.range : true
    externalSalesOrderRequestStatus : String enum {
      NOT_STARTED;
      IN_PROCESS;
      FINISHED;
      INTERRUPTED;
    };
    @title : 'Transfer Status'
    @assert.range : true
    transferStatus : String enum {
      NOT_STARTED;
      IN_PROCESS;
      FINISHED;
      INTERRUPTED;
    };
    campaign : {
      @title : 'Campaign Technical ID'
      id : UUID;
      @title : 'Campaign ID'
      displayId : String;
      @title : 'Campaign'
      description : String;
    };
    referenceUsages : { };
    extensions : { };
  };
};

@title : 'Sales Quote create request'
type Service_types.SalesQuotecreaterequest {
  isPrimary : Boolean;
  @title : 'Customer Reference'
  customerReferenceId : String;
  @title : 'Language Code'
  documentLanguage : String;
  documentDate : Date;
  @title : 'Description'
  name : String;
  @title : 'Document Type Code'
  documentType : String;
  validityPeriod : {
    startDate : Date;
    endDate : Date;
  };
  requestedFulfillmentPeriod : {
    startDateTime : Timestamp;
    endDateTime : Timestamp;
  };
  account : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Account ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Account'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
    @title : 'Technical ID'
    topAccountId : UUID;
    @title : 'Top Account ID'
    topAccountDisplayId : String;
    @title : 'Top Account'
    topAccountName : String;
    @title : 'Technical ID'
    parentAccountId : UUID;
    @title : 'Parent Account ID'
    parentAccountDisplayId : String;
    @title : 'Parent Account'
    parentAccountName : String;
  };
  individualCustomer : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Individual Customer ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Individual Customer'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  shipTo : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Ship-To ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Ship-To'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  shipToIndividualCustomer : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Ship-To Individual Customer ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Ship-To Individual Customer'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  billTo : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Bill-To ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Bill-To'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  billToIndividualCustomer : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Bill-To Individual Customer ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Bill-To Individual Customer'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  owner : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Owner ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Owner Name'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  contactOfAccount : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Contact ID of Account'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Contact of Account'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  salesEmployee : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Sales Employee ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Sales Employee'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  salesUnit : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Sales Unit ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Sales Unit'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  businessTerms : {
    @title : 'Delivery Priority Code'
    deliveryPriority : String;
    @title : 'Delivery Priority'
    deliveryPriorityDescription : String;
    @title : 'Currency Code'
    currency : String;
    @title : 'Currency'
    currencyDescription : String;
    priceDate : Date;
    probabilityPercent : Double;
    @title : 'Payment Terms Code'
    cashDiscountTerms : String;
    @title : 'Payment Terms'
    cashDiscountTermsDescription : String;
    incoterms : {
      @title : 'Incoterms Code'
      classification : String;
      @title : 'Incoterms'
      classificationDescription : String;
      @title : 'Incoterms Location'
      location : String;
    };
    @title : 'Customer Group Code'
    customerGroup : String;
    @title : 'Customer Group'
    customerGroupDescription : String;
  };
  @title : 'Status'
  @assert.range : true
  lifeCycleStatus : String enum {
    OPEN;
    IN_PROCESS;
    COMPLETED;
    INACTIVE_VERSION;
  };
  @title : 'Progress'
  @assert.range : true
  progressStatus : String enum {
    OPEN;
    IN_PROCESS;
    PENDING;
    WON;
    LOST;
    STOPPED;
  };
  @title : 'Code: Reason for Progress'
  progressStatusReason : String;
  parties : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Party Technical ID'
    partyId : UUID;
    @title : 'Party ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Name'
    partyName : String;
    isMain : Boolean;
    @title : 'Role Category'
    roleCategory : String;
    @title : 'Party Role'
    role : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String(255);
    @title : 'Email'
    email : String(255);
    @title : 'Phone'
    phoneFormattedNumber : String(40);
    @title : 'Mobile'
    mobileFormattedNumber : String(40);
    @title : 'Address ID'
    addressId : UUID;
    @title : 'House Number'
    houseId : String(10);
    @title : 'Country/Region'
    country : String;
    @title : 'Street'
    street : String(60);
    @title : 'City'
    city : String(40);
    @title : 'Postal Code'
    postalCode : String(10);
    region : {
      @title : 'Country/Region'
      country : String;
      @title : 'Region'
      region : String;
    };
    @title : 'Top Account ID'
    topAccountId : String;
    @title : 'Top Account'
    topAccountName : String;
    @title : 'Top Account ID'
    topAccountDisplayId : String;
    @title : 'Parent Account ID'
    parentAccountId : String;
    @title : 'Parent Account'
    parentAccountName : String;
    @title : 'Parent Account ID'
    parentAccountDisplayId : String;
    isInternal : Boolean;
  };
  salesTerritories : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Territory Technical ID'
    salesTerritoryId : UUID;
    @title : 'Territory ID'
    salesTerritoryDisplayId : String;
    @title : 'Territory'
    salesTerritoryName : String;
    isMain : Boolean;
    @title : 'Territory Determination Method Code'
    salesTerritoryDeterminationMethod : String;
    @title : 'Territory Determination Method'
    salesTerritoryDeterminationMethodDescription : String;
  };
  businessArea : {
    @title : 'Sales Organization Technical ID'
    salesOrganisationId : UUID;
    @title : 'Sales Organization ID'
    salesOrganisationDisplayId : String;
    @title : 'Sales Organization'
    salesOrganisationName : String;
    @title : 'Sales Organization Determination Method Code'
    salesOrganisationDeterminationMethod : String;
    @title : 'Sales Organization Determination Method'
    salesOrganisationDeterminationMethodDescription : String;
    @title : 'Sales Group Technical ID'
    salesGroupId : UUID;
    @title : 'Sales Group ID'
    salesGroupDisplayId : String;
    @title : 'Sales Group'
    salesGroupName : String;
    @title : 'Sales Group Determination Method Code'
    salesGroupDeterminationMethod : String;
    @title : 'Sales Group Determination Method'
    salesGroupDeterminationMethodDescription : String;
    @title : 'Sales Office Technical ID'
    salesOfficeId : UUID;
    @title : 'Sales Office ID'
    salesOfficeDisplayId : String;
    @title : 'Sales Office'
    salesOfficeName : String;
    @title : 'Sales Office Determination Method Code'
    salesOfficeDeterminationMethod : String;
    @title : 'Sales Office Determination Method'
    salesOfficeDeterminationMethodDescription : String;
    @title : 'Territory Technical ID'
    salesTerritoryId : UUID;
    @title : 'Territory ID'
    salesTerritoryDisplayId : String;
    @title : 'Territory'
    salesTerritoryName : String;
    @title : 'Territory Determination Method Code'
    salesTerritoryDeterminationMethod : String;
    @title : 'Territory Determination Method'
    salesTerritoryDeterminationMethodDescription : String;
    @title : 'Distribution Channel Code'
    distributionChannel : String;
    @title : 'Distribution Channel'
    distributionChannelDescription : String;
    @title : 'Distribution Channel Determination Method Code'
    distributionChannelDeterminationMethod : String;
    @title : 'Distribution Channel Determination Method'
    distributionChannelDeterminationMethodDescription : String;
    @title : 'Division Code'
    division : String;
    @title : 'Division'
    divisionDescription : String;
    @title : 'Division Determination Method Code'
    divisionDeterminationMethod : String;
    @title : 'Division Determination Method'
    divisionDeterminationMethodDescription : String;
  };
  notes : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Note Type'
    type : String;
    @title : 'Note'
    content : String;
    adminData : {
      @title : 'Created By (Technical ID)'
      createdBy : UUID;
      @title : 'Created By'
      createdByName : String;
      createdOn : Timestamp;
      @title : 'Changed By (Technical ID)'
      updatedBy : UUID;
      @title : 'Changed By'
      updatedByName : String;
      updatedOn : Timestamp;
    };
  };
  attachments : many {
    @title : 'ID'
    id : UUID;
    @title : 'Title'
    title : String;
    @title : 'Category'
    category : String;
    @title : 'File Name'
    fileName : String;
    @title : 'File Size'
    fileSize : String;
    @title : 'Content Type'
    contentType : String;
    @title : 'URL'
    url : String;
    adminData : {
      @title : 'Created By (Technical ID)'
      createdBy : UUID;
      @title : 'Created By'
      createdByName : String;
      createdOn : Timestamp;
      @title : 'Changed By (Technical ID)'
      updatedBy : UUID;
      @title : 'Changed By'
      updatedByName : String;
      updatedOn : Timestamp;
    };
  };
  items : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'ID'
    displayId : String(10);
    @title : 'Description'
    description : String;
    @title : 'Item Type'
    itemType : String;
    @title : 'Item Type'
    itemTypeDescription : String;
    @title : 'Type Code'
    @assert.range : true
    typeCode : String enum {
      PRODUCT;
      TEXT;
    };
    @title : 'Technical ID'
    parentItemId : UUID;
    @title : 'Parent ID'
    parentItemDisplayId : String(10);
    @title : 'ATP Status'
    @assert.range : true
    availabilityStatus : String enum {
      CONFIRMATION_PENDING;
      NOT_CONFIRMED;
      CONFIRMED_INSUFFICIENTLY;
      CONFIRMED_SUFFICIENTLY;
    };
    @title : 'Progress'
    @assert.range : true
    progressStatus : String enum {
      OPEN;
      IN_PROCESS;
      PENDING;
      WON;
      LOST;
      STOPPED;
    };
    @title : 'Reason for Progress Code'
    progressStatusReason : String;
    @title : 'Reason for Progress'
    progressStatusReasonDescription : String;
    productData : {
      @title : 'Product Technical ID'
      productId : UUID;
      @title : 'Product ID'
      productDisplayId : String;
      @title : 'Original Product Technical ID'
      originalProductId : UUID;
      @title : 'Original Product ID'
      originalProductDisplayId : String;
      @title : 'Product Category Technical ID'
      productCategoryId : UUID;
      @title : 'Product Category ID'
      productCategoryDisplayId : String;
      @title : 'Unit Code'
      productQuantityMeasureUnit : String;
      @title : 'Unit'
      productQuantityMeasureUnitDescription : String;
    };
    @title : 'Product List Technical ID'
    productListId : UUID;
    @title : 'Product List'
    productListDisplayId : String;
    attachments : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'lbl_salesQuoteAttachment_attachmentType'
      type : String;
      @title : 'lbl_salesQuoteAttachment_textContent'
      content : String;
      adminData : {
        @title : 'Created By (Technical ID)'
        createdBy : UUID;
        @title : 'Created By'
        createdByName : String;
        createdOn : Timestamp;
        @title : 'Changed By (Technical ID)'
        updatedBy : UUID;
        @title : 'Changed By'
        updatedByName : String;
        updatedOn : Timestamp;
      };
    };
    scheduleLines : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'ID'
      displayId : String(4);
      quantity : {
        content : Double;
        @title : 'Unit'
        uomCode : String;
      };
      confirmedQuantity : {
        content : Double;
        @title : 'Unit'
        uomCode : String;
      };
      originalQuantity : {
        content : Double;
        @title : 'Unit'
        uomCode : String;
      };
      period : {
        startDateTime : Timestamp;
        endDateTime : Timestamp;
      };
    };
    notes : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Note Type'
      type : String;
      @title : 'Note'
      content : String;
      adminData : {
        @title : 'Created By (Technical ID)'
        createdBy : UUID;
        @title : 'Created By'
        createdByName : String;
        createdOn : Timestamp;
        @title : 'Changed By (Technical ID)'
        updatedBy : UUID;
        @title : 'Changed By'
        updatedByName : String;
        updatedOn : Timestamp;
      };
    };
    @title : 'Usage Type'
    @assert.range : true
    usageType : String enum {
      PRODUCT_SUBSTITUTION;
      BILL_OF_MATERIAL;
      FREE_GOOD;
      CROSS_SELL;
      UP_SELL;
      DOWN_SELL;
      NONE;
    };
    totalValues : {
      netAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      grossAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      taxAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      requestedQuantity : {
        content : Double;
        @title : 'Unit'
        uomCode : String;
      };
      confirmedQuantity : {
        content : Double;
        @title : 'Unit'
        uomCode : String;
      };
      netPrice : {
        amount : {
          content : Double;
          @title : 'Currency'
          currencyCode : String;
        };
        baseQuantity : {
          content : Double;
          @title : 'Unit'
          uomCode : String;
        };
      };
    };
    adminData : {
      @title : 'Created By (Technical ID)'
      createdBy : UUID;
      @title : 'Created By'
      createdByName : String;
      createdOn : Timestamp;
      @title : 'Changed By (Technical ID)'
      updatedBy : UUID;
      @title : 'Changed By'
      updatedByName : String;
      updatedOn : Timestamp;
    };
    businessTerms : {
      @title : 'Delivery Priority Code'
      deliveryPriority : String;
      @title : 'Delivery Priority'
      deliveryPriorityDescription : String;
      @title : 'Currency Code'
      currency : String;
      @title : 'Currency'
      currencyDescription : String;
      priceDate : Date;
      probabilityPercent : Double;
      @title : 'Payment Terms Code'
      cashDiscountTerms : String;
      @title : 'Payment Terms'
      cashDiscountTermsDescription : String;
      @title : 'Customer Group Code'
      customerGroup : String;
      @title : 'Customer Group'
      customerGroupDescription : String;
      incoterms : {
        @title : 'Incoterms Code'
        classification : String;
        @title : 'Incoterms'
        classificationDescription : String;
        @title : 'Incoterms Location'
        location : String;
      };
    };
    priceElements : many {
      @title : 'Price Element ID'
      id : UUID;
      @title : 'Price Element Description'
      description : String;
      stepNumber : Decimal;
      counter : Decimal;
      @title : 'Price Element Condition Type'
      conditionType : String;
      @title : 'Price Element Category Code'
      categoryCode : String;
      @title : 'Price Element Origin Code'
      originCode : String;
      calculatedAmount : {
        content : Double;
        @title : 'Price Element Net Currency'
        currencyCode : String;
      };
      rateAmount : {
        content : Double;
        @title : 'Price Element Net Price Currency'
        currencyCode : String;
      };
      rateBaseQuantity : {
        content : Double;
        @title : 'Price Element Unit of Measure'
        uomCode : String;
      };
      isManuallyChanged : Boolean;
      isDeleteEnabled : Boolean;
      @title : 'Reason Code for Inactive Price Element'
      inactiveReasonCode : String;
      isEffective : Boolean;
    };
    @title : 'Customer Part Number'
    customerPartNumber : String;
    @title : 'GTIN'
    gtin : String;
    referenceUsages : { };
    extensions : { };
  };
  relatedObjects : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Related Entity Technical ID'
    objectId : String;
    @title : 'Related Entity ID'
    displayId : String;
    @title : 'Related Entity Type'
    type : String;
    @title : 'Related Entity Role'
    role : String;
    @title : 'Communication System ID'
    communicationSystemId : String;
    @title : 'Communication System'
    communicationSystemDisplayId : String;
  };
  externalId : {
    @title : 'Technical ID'
    id : UUID;
    @title : 'External ID'
    displayId : String;
    @title : 'Communication System'
    communicationSystemDisplayId : String;
    @title : 'Communication System ID'
    communicationSystemId : UUID;
  };
  @title : 'Pricing Procedure'
  pricingProcedureName : String;
  priceElements : many {
    @title : 'Price Element ID'
    id : UUID;
    @title : 'Price Element Description'
    description : String;
    stepNumber : Decimal;
    counter : Decimal;
    @title : 'Price Element Condition Type'
    conditionType : String;
    @title : 'Price Element Category Code'
    categoryCode : String;
    @title : 'Price Element Origin Code'
    originCode : String;
    calculatedAmount : {
      content : Double;
      @title : 'Price Element Net Currency'
      currencyCode : String;
    };
    rateAmount : {
      content : Double;
      @title : 'Price Element Net Price Currency'
      currencyCode : String;
    };
    rateBaseQuantity : {
      content : Double;
      @title : 'Price Element Unit of Measure'
      uomCode : String;
    };
    isManuallyChanged : Boolean;
    isDeleteEnabled : Boolean;
    @title : 'Reason Code for Inactive Price Element'
    inactiveReasonCode : String;
    isEffective : Boolean;
  };
  campaign : {
    @title : 'Campaign Technical ID'
    id : UUID;
    @title : 'Campaign ID'
    displayId : String;
    @title : 'Campaign'
    description : String;
  };
  referenceUsages : { };
  extensions : { };
};

@title : 'Sales Quote patchupdate request'
type Service_types.SalesQuotepatchupdaterequest {
  isPrimary : Boolean;
  @title : 'Customer Reference'
  customerReferenceId : String;
  @title : 'Language Code'
  documentLanguage : String;
  documentDate : Date;
  @title : 'Description'
  name : String;
  validityPeriod : {
    startDate : Date;
    endDate : Date;
  };
  requestedFulfillmentPeriod : {
    startDateTime : Timestamp;
    endDateTime : Timestamp;
  };
  account : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Account ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Account'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
    @title : 'Technical ID'
    topAccountId : UUID;
    @title : 'Top Account ID'
    topAccountDisplayId : String;
    @title : 'Top Account'
    topAccountName : String;
    @title : 'Technical ID'
    parentAccountId : UUID;
    @title : 'Parent Account ID'
    parentAccountDisplayId : String;
    @title : 'Parent Account'
    parentAccountName : String;
  };
  individualCustomer : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Individual Customer ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Individual Customer'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  shipTo : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Ship-To ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Ship-To'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  shipToIndividualCustomer : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Ship-To Individual Customer ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Ship-To Individual Customer'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  billTo : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Bill-To ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Bill-To'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  billToIndividualCustomer : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Bill-To Individual Customer ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Bill-To Individual Customer'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  owner : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Owner ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Owner Name'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  contactOfAccount : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Contact ID of Account'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Contact of Account'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  salesEmployee : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Sales Employee ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Sales Employee'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  salesUnit : {
    @title : 'Technical ID'
    partyId : UUID;
    @title : 'Sales Unit ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Sales Unit'
    partyName : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String;
    @title : 'Email'
    email : String;
    @title : 'Phone'
    phoneFormattedNumber : String;
    @title : 'Mobile'
    mobileFormattedNumber : String;
  };
  businessTerms : {
    @title : 'Delivery Priority Code'
    deliveryPriority : String;
    @title : 'Delivery Priority'
    deliveryPriorityDescription : String;
    @title : 'Currency Code'
    currency : String;
    @title : 'Currency'
    currencyDescription : String;
    priceDate : Date;
    probabilityPercent : Double;
    @title : 'Payment Terms Code'
    cashDiscountTerms : String;
    @title : 'Payment Terms'
    cashDiscountTermsDescription : String;
    incoterms : {
      @title : 'Incoterms Code'
      classification : String;
      @title : 'Incoterms'
      classificationDescription : String;
      @title : 'Incoterms Location'
      location : String;
    };
    @title : 'Customer Group Code'
    customerGroup : String;
    @title : 'Customer Group'
    customerGroupDescription : String;
  };
  @title : 'Status'
  @assert.range : true
  lifeCycleStatus : String enum {
    OPEN;
    IN_PROCESS;
    COMPLETED;
    INACTIVE_VERSION;
  };
  @title : 'Progress'
  @assert.range : true
  progressStatus : String enum {
    OPEN;
    IN_PROCESS;
    PENDING;
    WON;
    LOST;
    STOPPED;
  };
  @title : 'Code: Reason for Progress'
  progressStatusReason : String;
  parties : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Party Technical ID'
    partyId : UUID;
    @title : 'Party ID'
    partyDisplayId : String;
    @title : 'Type'
    type : String;
    @title : 'Name'
    partyName : String;
    isMain : Boolean;
    @title : 'Role Category'
    roleCategory : String;
    @title : 'Party Role'
    role : String;
    @title : 'Determination Method Code'
    determinationMethod : String;
    @title : 'Determination Method'
    determinationMethodDescription : String;
    @title : 'Address'
    formattedPostalAddress : String(255);
    @title : 'Email'
    email : String(255);
    @title : 'Phone'
    phoneFormattedNumber : String(40);
    @title : 'Mobile'
    mobileFormattedNumber : String(40);
    @title : 'Address ID'
    addressId : UUID;
    @title : 'House Number'
    houseId : String(10);
    @title : 'Country/Region'
    country : String;
    @title : 'Street'
    street : String(60);
    @title : 'City'
    city : String(40);
    @title : 'Postal Code'
    postalCode : String(10);
    region : {
      @title : 'Country/Region'
      country : String;
      @title : 'Region'
      region : String;
    };
    @title : 'Top Account ID'
    topAccountId : String;
    @title : 'Top Account'
    topAccountName : String;
    @title : 'Top Account ID'
    topAccountDisplayId : String;
    @title : 'Parent Account ID'
    parentAccountId : String;
    @title : 'Parent Account'
    parentAccountName : String;
    @title : 'Parent Account ID'
    parentAccountDisplayId : String;
    isInternal : Boolean;
  };
  salesTerritories : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Territory Technical ID'
    salesTerritoryId : UUID;
    @title : 'Territory ID'
    salesTerritoryDisplayId : String;
    @title : 'Territory'
    salesTerritoryName : String;
    isMain : Boolean;
    @title : 'Territory Determination Method Code'
    salesTerritoryDeterminationMethod : String;
    @title : 'Territory Determination Method'
    salesTerritoryDeterminationMethodDescription : String;
  };
  businessArea : {
    @title : 'Sales Organization Technical ID'
    salesOrganisationId : UUID;
    @title : 'Sales Organization ID'
    salesOrganisationDisplayId : String;
    @title : 'Sales Organization'
    salesOrganisationName : String;
    @title : 'Sales Organization Determination Method Code'
    salesOrganisationDeterminationMethod : String;
    @title : 'Sales Organization Determination Method'
    salesOrganisationDeterminationMethodDescription : String;
    @title : 'Sales Group Technical ID'
    salesGroupId : UUID;
    @title : 'Sales Group ID'
    salesGroupDisplayId : String;
    @title : 'Sales Group'
    salesGroupName : String;
    @title : 'Sales Group Determination Method Code'
    salesGroupDeterminationMethod : String;
    @title : 'Sales Group Determination Method'
    salesGroupDeterminationMethodDescription : String;
    @title : 'Sales Office Technical ID'
    salesOfficeId : UUID;
    @title : 'Sales Office ID'
    salesOfficeDisplayId : String;
    @title : 'Sales Office'
    salesOfficeName : String;
    @title : 'Sales Office Determination Method Code'
    salesOfficeDeterminationMethod : String;
    @title : 'Sales Office Determination Method'
    salesOfficeDeterminationMethodDescription : String;
    @title : 'Territory Technical ID'
    salesTerritoryId : UUID;
    @title : 'Territory ID'
    salesTerritoryDisplayId : String;
    @title : 'Territory'
    salesTerritoryName : String;
    @title : 'Territory Determination Method Code'
    salesTerritoryDeterminationMethod : String;
    @title : 'Territory Determination Method'
    salesTerritoryDeterminationMethodDescription : String;
    @title : 'Distribution Channel Code'
    distributionChannel : String;
    @title : 'Distribution Channel'
    distributionChannelDescription : String;
    @title : 'Distribution Channel Determination Method Code'
    distributionChannelDeterminationMethod : String;
    @title : 'Distribution Channel Determination Method'
    distributionChannelDeterminationMethodDescription : String;
    @title : 'Division Code'
    division : String;
    @title : 'Division'
    divisionDescription : String;
    @title : 'Division Determination Method Code'
    divisionDeterminationMethod : String;
    @title : 'Division Determination Method'
    divisionDeterminationMethodDescription : String;
  };
  notes : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Note Type'
    type : String;
    @title : 'Note'
    content : String;
    adminData : {
      @title : 'Created By (Technical ID)'
      createdBy : UUID;
      @title : 'Created By'
      createdByName : String;
      createdOn : Timestamp;
      @title : 'Changed By (Technical ID)'
      updatedBy : UUID;
      @title : 'Changed By'
      updatedByName : String;
      updatedOn : Timestamp;
    };
  };
  attachments : many {
    @title : 'ID'
    id : UUID;
    @title : 'Title'
    title : String;
    @title : 'Category'
    category : String;
    @title : 'File Name'
    fileName : String;
    @title : 'File Size'
    fileSize : String;
    @title : 'Content Type'
    contentType : String;
    @title : 'URL'
    url : String;
    adminData : {
      @title : 'Created By (Technical ID)'
      createdBy : UUID;
      @title : 'Created By'
      createdByName : String;
      createdOn : Timestamp;
      @title : 'Changed By (Technical ID)'
      updatedBy : UUID;
      @title : 'Changed By'
      updatedByName : String;
      updatedOn : Timestamp;
    };
  };
  items : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'ID'
    displayId : String(10);
    @title : 'Description'
    description : String;
    @title : 'Item Type'
    itemType : String;
    @title : 'Item Type'
    itemTypeDescription : String;
    @title : 'Type Code'
    @assert.range : true
    typeCode : String enum {
      PRODUCT;
      TEXT;
    };
    @title : 'Technical ID'
    parentItemId : UUID;
    @title : 'Parent ID'
    parentItemDisplayId : String(10);
    @title : 'ATP Status'
    @assert.range : true
    availabilityStatus : String enum {
      CONFIRMATION_PENDING;
      NOT_CONFIRMED;
      CONFIRMED_INSUFFICIENTLY;
      CONFIRMED_SUFFICIENTLY;
    };
    @title : 'Progress'
    @assert.range : true
    progressStatus : String enum {
      OPEN;
      IN_PROCESS;
      PENDING;
      WON;
      LOST;
      STOPPED;
    };
    @title : 'Reason for Progress Code'
    progressStatusReason : String;
    @title : 'Reason for Progress'
    progressStatusReasonDescription : String;
    productData : {
      @title : 'Product Technical ID'
      productId : UUID;
      @title : 'Product ID'
      productDisplayId : String;
      @title : 'Original Product Technical ID'
      originalProductId : UUID;
      @title : 'Original Product ID'
      originalProductDisplayId : String;
      @title : 'Product Category Technical ID'
      productCategoryId : UUID;
      @title : 'Product Category ID'
      productCategoryDisplayId : String;
      @title : 'Unit Code'
      productQuantityMeasureUnit : String;
      @title : 'Unit'
      productQuantityMeasureUnitDescription : String;
    };
    @title : 'Product List Technical ID'
    productListId : UUID;
    @title : 'Product List'
    productListDisplayId : String;
    attachments : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'lbl_salesQuoteAttachment_attachmentType'
      type : String;
      @title : 'lbl_salesQuoteAttachment_textContent'
      content : String;
      adminData : {
        @title : 'Created By (Technical ID)'
        createdBy : UUID;
        @title : 'Created By'
        createdByName : String;
        createdOn : Timestamp;
        @title : 'Changed By (Technical ID)'
        updatedBy : UUID;
        @title : 'Changed By'
        updatedByName : String;
        updatedOn : Timestamp;
      };
    };
    scheduleLines : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'ID'
      displayId : String(4);
      quantity : {
        content : Double;
        @title : 'Unit'
        uomCode : String;
      };
      confirmedQuantity : {
        content : Double;
        @title : 'Unit'
        uomCode : String;
      };
      originalQuantity : {
        content : Double;
        @title : 'Unit'
        uomCode : String;
      };
      period : {
        startDateTime : Timestamp;
        endDateTime : Timestamp;
      };
    };
    notes : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Note Type'
      type : String;
      @title : 'Note'
      content : String;
      adminData : {
        @title : 'Created By (Technical ID)'
        createdBy : UUID;
        @title : 'Created By'
        createdByName : String;
        createdOn : Timestamp;
        @title : 'Changed By (Technical ID)'
        updatedBy : UUID;
        @title : 'Changed By'
        updatedByName : String;
        updatedOn : Timestamp;
      };
    };
    @title : 'Usage Type'
    @assert.range : true
    usageType : String enum {
      PRODUCT_SUBSTITUTION;
      BILL_OF_MATERIAL;
      FREE_GOOD;
      CROSS_SELL;
      UP_SELL;
      DOWN_SELL;
      NONE;
    };
    totalValues : {
      netAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      grossAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      taxAmount : {
        content : Double;
        @title : 'Currency'
        currencyCode : String;
      };
      requestedQuantity : {
        content : Double;
        @title : 'Unit'
        uomCode : String;
      };
      confirmedQuantity : {
        content : Double;
        @title : 'Unit'
        uomCode : String;
      };
      netPrice : {
        amount : {
          content : Double;
          @title : 'Currency'
          currencyCode : String;
        };
        baseQuantity : {
          content : Double;
          @title : 'Unit'
          uomCode : String;
        };
      };
    };
    adminData : {
      @title : 'Created By (Technical ID)'
      createdBy : UUID;
      @title : 'Created By'
      createdByName : String;
      createdOn : Timestamp;
      @title : 'Changed By (Technical ID)'
      updatedBy : UUID;
      @title : 'Changed By'
      updatedByName : String;
      updatedOn : Timestamp;
    };
    businessTerms : {
      @title : 'Delivery Priority Code'
      deliveryPriority : String;
      @title : 'Delivery Priority'
      deliveryPriorityDescription : String;
      @title : 'Currency Code'
      currency : String;
      @title : 'Currency'
      currencyDescription : String;
      priceDate : Date;
      probabilityPercent : Double;
      @title : 'Payment Terms Code'
      cashDiscountTerms : String;
      @title : 'Payment Terms'
      cashDiscountTermsDescription : String;
      @title : 'Customer Group Code'
      customerGroup : String;
      @title : 'Customer Group'
      customerGroupDescription : String;
      incoterms : {
        @title : 'Incoterms Code'
        classification : String;
        @title : 'Incoterms'
        classificationDescription : String;
        @title : 'Incoterms Location'
        location : String;
      };
    };
    priceElements : many {
      @title : 'Price Element ID'
      id : UUID;
      @title : 'Price Element Description'
      description : String;
      stepNumber : Decimal;
      counter : Decimal;
      @title : 'Price Element Condition Type'
      conditionType : String;
      @title : 'Price Element Category Code'
      categoryCode : String;
      @title : 'Price Element Origin Code'
      originCode : String;
      calculatedAmount : {
        content : Double;
        @title : 'Price Element Net Currency'
        currencyCode : String;
      };
      rateAmount : {
        content : Double;
        @title : 'Price Element Net Price Currency'
        currencyCode : String;
      };
      rateBaseQuantity : {
        content : Double;
        @title : 'Price Element Unit of Measure'
        uomCode : String;
      };
      isManuallyChanged : Boolean;
      isDeleteEnabled : Boolean;
      @title : 'Reason Code for Inactive Price Element'
      inactiveReasonCode : String;
      isEffective : Boolean;
    };
    @title : 'Customer Part Number'
    customerPartNumber : String;
    @title : 'GTIN'
    gtin : String;
    referenceUsages : { };
    extensions : { };
  };
  relatedObjects : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Related Entity Technical ID'
    objectId : String;
    @title : 'Related Entity ID'
    displayId : String;
    @title : 'Related Entity Type'
    type : String;
    @title : 'Related Entity Role'
    role : String;
    @title : 'Communication System ID'
    communicationSystemId : String;
    @title : 'Communication System'
    communicationSystemDisplayId : String;
  };
  externalId : {
    @title : 'Technical ID'
    id : UUID;
    @title : 'External ID'
    displayId : String;
    @title : 'Communication System'
    communicationSystemDisplayId : String;
    @title : 'Communication System ID'
    communicationSystemId : UUID;
  };
  @title : 'Pricing Procedure'
  pricingProcedureName : String;
  priceElements : many {
    @title : 'Price Element ID'
    id : UUID;
    @title : 'Price Element Description'
    description : String;
    stepNumber : Decimal;
    counter : Decimal;
    @title : 'Price Element Condition Type'
    conditionType : String;
    @title : 'Price Element Category Code'
    categoryCode : String;
    @title : 'Price Element Origin Code'
    originCode : String;
    calculatedAmount : {
      content : Double;
      @title : 'Price Element Net Currency'
      currencyCode : String;
    };
    rateAmount : {
      content : Double;
      @title : 'Price Element Net Price Currency'
      currencyCode : String;
    };
    rateBaseQuantity : {
      content : Double;
      @title : 'Price Element Unit of Measure'
      uomCode : String;
    };
    isManuallyChanged : Boolean;
    isDeleteEnabled : Boolean;
    @title : 'Reason Code for Inactive Price Element'
    inactiveReasonCode : String;
    isEffective : Boolean;
  };
  campaign : {
    @title : 'Campaign Technical ID'
    id : UUID;
    @title : 'Campaign ID'
    displayId : String;
    @title : 'Campaign'
    description : String;
  };
  referenceUsages : { };
  extensions : { };
};

