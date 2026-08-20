/* checksum : 7b20d6605b360d6cbcbbc27ac74775fa */
namespace Organizational.Unit;

@Capabilities.BatchSupported : false
@Capabilities.KeyAsSegmentSupported : true
@Core.Description : 'Organizational Unit Service'
@Core.SchemaVersion : '1.0.0'
@Core.LongDescription : 'Organizational unit contains a hierarchy that represents the hierarchical structure of the organization. Use this API to query, read, create, and update organizational units.'
service Service {
  @Common.Label : 'Distribution Channel'
  @Core.Description : 'Read distribution channel records.'
  @Core.LongDescription : 'Specify query parameters to return desired distribution channel code records from the system.'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/distributionChannels'
  function sap_c4c_api_v1_organizational_unit_service_distributionChannels(
    @description : 'Show only the first n distribution channels.'
    @openapi.in : 'query'
    @openapi.name : '$top'
    _top : Integer,
    @description : 'Skip the first n distribution channels.'
    @openapi.in : 'query'
    @openapi.name : '$skip'
    _skip : Integer,
    @description : 'Search for a string within distribution channels.'
    @openapi.in : 'query'
    @openapi.name : '$search'
    _search : String,
    @description : 'Filter distribution channels by attribute.'
    @openapi.in : 'query'
    @openapi.name : '$filter'
    _filter : String,
    @description : 'Order distribution channels by attribute.'
    @openapi.in : 'query'
    @openapi.name : '$orderby'
    _orderby : String
  ) returns Service_types.DistributionChannelqueryresponse;

  @Common.Label : 'Distribution Channel'
  @Core.Description : 'Create a new distribution channel.'
  @Core.LongDescription : 'Send distribution channel code information to the system to create a new distribution channel.'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/distributionChannels'
  action sap_c4c_api_v1_organizational_unit_service_distributionChannels_post(
    @openapi.in : 'body'
    body : Service_types.DistributionChannelcreaterequest
  ) returns Service_types.DistributionChannelfile;

  @Common.Label : 'Distribution Channel'
  @Core.Description : 'Read distribution channel information.'
  @Core.LongDescription : 'Read a specific distribution channel code using the code Value.'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/distributionChannels/{code}'
  function sap_c4c_api_v1_organizational_unit_service_distributionChannels_(
    @openapi.in : 'path'
    code : String
  ) returns Service_types.DistributionChannelfile;

  @Common.Label : 'Distribution Channel'
  @Core.Description : 'Create or update distribution channel'
  @Core.LongDescription : 'Full update of distribution channel.'
  @openapi.method : 'PUT'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/distributionChannels/{code}'
  action sap_c4c_api_v1_organizational_unit_service_distributionChannels__put(
    @description : 'Distribution channel code'
    @openapi.in : 'path'
    code : String,
    @openapi.in : 'body'
    body : Service_types.DistributionChannelupdaterequest
  ) returns Service_types.DistributionChannelfile;

  @Common.Label : 'Distribution Channel'
  @Core.Description : 'Delete distribution channel'
  @Core.LongDescription : 'Delete a distribution channel in system.'
  @openapi.method : 'DELETE'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/distributionChannels/{code}'
  action sap_c4c_api_v1_organizational_unit_service_distributionChannels__delete(
    @description : 'Distribution channel code'
    @openapi.in : 'path'
    code : String
  );

  @Common.Label : 'Division'
  @Core.Description : 'Query divisions'
  @Core.LongDescription : 'Specify query parameters to return desired division code records from the system.'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/divisions'
  function sap_c4c_api_v1_organizational_unit_service_divisions(
    @description : 'Show only the first n divisions.'
    @openapi.in : 'query'
    @openapi.name : '$top'
    _top : Integer,
    @description : 'Skip the first n divisions.'
    @openapi.in : 'query'
    @openapi.name : '$skip'
    _skip : Integer,
    @description : 'Search for a string within divisions.'
    @openapi.in : 'query'
    @openapi.name : '$search'
    _search : String,
    @description : 'Filter divisions by attribute.'
    @openapi.in : 'query'
    @openapi.name : '$filter'
    _filter : String,
    @description : 'Order divisions by attribute.'
    @openapi.in : 'query'
    @openapi.name : '$orderby'
    _orderby : String
  ) returns Service_types.Divisionqueryresponse;

  @Common.Label : 'Division'
  @Core.Description : 'Create a division.'
  @Core.LongDescription : 'Send division code information to the system to create a new division.'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/divisions'
  action sap_c4c_api_v1_organizational_unit_service_divisions_post(
    @openapi.in : 'body'
    body : Service_types.Divisioncreaterequest
  ) returns Service_types.Divisionfile;

  @Common.Label : 'Division'
  @Core.Description : 'Read division information.'
  @Core.LongDescription : 'Read a specific division code using the code Value.'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/divisions/{code}'
  function sap_c4c_api_v1_organizational_unit_service_divisions_(
    @openapi.in : 'path'
    code : String
  ) returns Service_types.Divisionfile;

  @Common.Label : 'Division'
  @Core.Description : 'Create or update division'
  @Core.LongDescription : 'Full update of division.'
  @openapi.method : 'PUT'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/divisions/{code}'
  action sap_c4c_api_v1_organizational_unit_service_divisions__put(
    @description : 'Division code'
    @openapi.in : 'path'
    code : String,
    @openapi.in : 'body'
    body : Service_types.Divisionupdaterequest
  ) returns Service_types.Divisionfile;

  @Common.Label : 'Division'
  @Core.Description : 'Delete division'
  @Core.LongDescription : 'Delete a division in system.'
  @openapi.method : 'DELETE'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/divisions/{code}'
  action sap_c4c_api_v1_organizational_unit_service_divisions__delete(
    @description : 'Division code'
    @openapi.in : 'path'
    code : String
  );

  @Common.Label : 'Organizational Unit'
  @Core.Description : 'Query organizational units'
  @Core.LongDescription : 'Specify query parameters to return desired organizational unit records from the system.'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/organizationalUnits'
  function sap_c4c_api_v1_organizational_unit_service_organizationalUnits(
    @description : 'Skip the first n organizational units.'
    @openapi.in : 'query'
    @openapi.name : '$skip'
    _skip : Integer,
    @description : 'Show only the first n organizational units.'
    @openapi.in : 'query'
    @openapi.name : '$top'
    _top : Integer,
    @description : 'Search for a string within organizational units.'
    @openapi.in : 'query'
    @openapi.name : '$search'
    _search : String,
    @description : 'Filter organizational units by attribute.'
    @openapi.in : 'query'
    @openapi.name : '$filter'
    _filter : String,
    @description : 'Order organizational units by attribute.'
    @openapi.in : 'query'
    @openapi.name : '$orderby'
    _orderby : String,
    @description : 'Select attributes to be returned.'
    @openapi.in : 'query'
    @openapi.name : '$select'
    _select : String,
    @description : 'Exclude attributes from response.'
    @openapi.in : 'query'
    @openapi.name : '$exclude'
    _exclude : String,
    @description : 'Run a specific query in organizational unit service.'
    @openapi.in : 'query'
    @openapi.name : '$query'
    _query : String
  ) returns Service_types.OrganizationalUnitqueryresponse;

  @Common.Label : 'Organizational Unit'
  @Core.Description : 'Create organizational unit'
  @Core.LongDescription : 'Send organizational unit information to the system to create a new organizational unit entity.'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/organizationalUnits'
  action sap_c4c_api_v1_organizational_unit_service_organizationalUnits_post(
    @openapi.in : 'body'
    body : Service_types.OrganizationalUnitcreaterequest
  ) returns Service_types.OrganizationalUnitfile;

  @Common.Label : 'Organizational Unit'
  @Core.Description : 'Read organizational unit'
  @Core.LongDescription : 'Read a specific organizational unit using the organizational unit ID.'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/organizationalUnits/{id}'
  function sap_c4c_api_v1_organizational_unit_service_organizationalUnits_(
    @description : 'Organizational unit ID'
    @openapi.in : 'path'
    id : UUID
  ) returns Service_types.OrganizationalUnitfile;

  @Common.Label : 'Organizational Unit'
  @Core.Description : 'Create or update organizational unit'
  @Core.LongDescription : 'Full update of organizational unit.'
  @openapi.method : 'PUT'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/organizationalUnits/{id}'
  action sap_c4c_api_v1_organizational_unit_service_organizationalUnits__put(
    @description : 'Organizational unit ID'
    @openapi.in : 'path'
    id : UUID,
    @openapi.in : 'body'
    body : Service_types.OrganizationalUnitupdaterequest
  ) returns Service_types.OrganizationalUnitfile;

  @Common.Label : 'Organizational Unit'
  @Core.Description : 'Update organizational unit attributes'
  @Core.LongDescription : 'Update organizational unit attributes in the system.'
  @openapi.method : 'PATCH'
  @openapi.path : '/sap/c4c/api/v1/organizational-unit-service/organizationalUnits/{id}'
  action sap_c4c_api_v1_organizational_unit_service_organizationalUnits__patch(
    @description : 'Organizational unit ID'
    @openapi.in : 'path'
    id : UUID,
    @openapi.contentType : 'application/merge-patch+json'
    @openapi.in : 'body'
    body : Service_types.OrganizationalUnitpatchupdaterequest
  ) returns Service_types.OrganizationalUnitfile;
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

@title : 'DistributionChannel query response'
type Service_types.DistributionChannelqueryresponse {
  count : Integer;
  value : many {
    code : String(2);
    description : String(255);
    descriptions : many {
      content : String(255);
      languageCode : String(5);
    };
  };
};

@title : 'DistributionChannel file'
type Service_types.DistributionChannelfile {
  value : {
    code : String(2);
    description : String(255);
    descriptions : many {
      content : String(255);
      languageCode : String(5);
    };
  };
};

@title : 'DistributionChannel create request'
type Service_types.DistributionChannelcreaterequest {
  code : String(2);
  description : String(255);
  descriptions : many {
    content : String(255);
    languageCode : String(5);
  };
};

@title : 'DistributionChannel update request'
type Service_types.DistributionChannelupdaterequest {
  description : String(255);
  descriptions : many {
    content : String(255);
    languageCode : String(5);
  };
};

@title : 'Division query response'
type Service_types.Divisionqueryresponse {
  count : Integer;
  value : many {
    code : String(2);
    description : String(255);
    descriptions : many {
      content : String(255);
      languageCode : String(5);
    };
  };
};

@title : 'Division file'
type Service_types.Divisionfile {
  value : {
    code : String(2);
    description : String(255);
    descriptions : many {
      content : String(255);
      languageCode : String(5);
    };
  };
};

@title : 'Division create request'
type Service_types.Divisioncreaterequest {
  code : String(2);
  description : String(255);
  descriptions : many {
    content : String(255);
    languageCode : String(5);
  };
};

@title : 'Division update request'
type Service_types.Divisionupdaterequest {
  description : String(255);
  descriptions : many {
    content : String(255);
    languageCode : String(5);
  };
};

@title : 'OrganizationalUnit query response'
type Service_types.OrganizationalUnitqueryresponse {
  count : Integer;
  value : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    adminData : {
      createdOn : Timestamp;
      @title : 'Created By'
      createdBy : UUID;
      @title : 'Created By Name'
      createdByName : String(255);
      updatedOn : Timestamp;
      @title : 'Changed By'
      updatedBy : UUID;
      @title : 'Changed By Name'
      updatedByName : String(255);
    };
    @title : 'Organizational Unit ID'
    displayId : String(50);
    @title : 'Name'
    name : String(40);
    @title : 'Status'
    lifeCycleStatus : String(14);
    @title : 'Status'
    lifeCycleStatusDescription : String(50);
    currentFunctions : {
      isCompany : Boolean;
      isSalesOrganization : Boolean;
      isServiceOrganization : Boolean;
      isSalesOffice : Boolean;
      isSalesGroup : Boolean;
      isSalesUnit : Boolean;
      isServiceUnit : Boolean;
      isBusinessUnit : Boolean;
      @title : 'Currency'
      currency : String(3);
      @title : 'Currency'
      currencyDescription : String(50);
    };
    reportingLineManager : {
      @title : 'Manager Technical ID'
      id : UUID;
      @title : 'Manager ID'
      displayId : String(10);
      @title : 'Manager Name'
      name : String(255);
    };
    reportingLineParentOrganizationalUnit : {
      @title : 'Parent Unit Technical ID'
      id : UUID;
      @title : 'Parent Unit ID'
      displayId : String(50);
      @title : 'Parent Unit Name'
      name : String(40);
    };
    address : {
      @title : 'Country/Region'
      country : String(3);
      @title : 'Country/Region'
      countryDescription : String(255);
      region : {
        @title : 'State'
        country : String(3);
        @title : 'State'
        region : String(6);
      };
      @title : 'State'
      regionDescription : String(255);
      @title : 'Postal Code'
      postalCode : String(10);
      @title : 'City'
      cityName : String(40);
      @title : 'Street'
      streetName : String(80);
      @title : 'House Number'
      houseId : String(10);
      @title : 'County'
      countyName : String(40);
      @title : 'District'
      districtName : String(40);
      @title : 'Address Line 1'
      streetPrefixName : String(40);
      @title : 'Address Line 2'
      additionalStreetPrefixName : String(40);
      @title : 'Address Line 4'
      streetSuffixName : String(40);
      @title : 'Address Line 5'
      additionalStreetSuffixName : String(40);
      latitudeMeasure : Decimal;
      longitudeMeasure : Decimal;
      @title : 'Address'
      formattedPostalAddressDescription : String(255);
    };
    communication : {
      @title : 'Email'
      eMail : String(255);
      @title : 'Website'
      web : String(1280);
      @title : 'Fax'
      facsimileFormattedNumber : String(40);
      @title : 'Phone'
      phoneFormattedNumber : String(40);
      @title : 'Normalized Phone'
      phoneNormalisedNumber : String(40);
      @title : 'Mobile'
      mobileFormattedNumber : String(40);
      @title : 'Normalized Mobile'
      mobileNormalisedNumber : String(40);
    };
    employeeAssignments : many {
      @title : 'Technical ID'
      id : UUID;
      validFrom : Date;
      validTo : Date;
      @title : 'Employee Technical ID'
      employeeId : UUID;
      employeeDisplayId : String(10);
      @title : 'Employee Name'
      employeeName : String(255);
      @title : 'Role'
      role : String(10);
      @title : 'Role'
      roleDescription : String(50);
    };
    functions : many {
      @title : 'Technical ID'
      id : UUID;
      validFrom : Date;
      validTo : Date;
      isCompany : Boolean;
      isSalesOrganization : Boolean;
      isServiceOrganization : Boolean;
      isSalesOffice : Boolean;
      isSalesGroup : Boolean;
      isSalesUnit : Boolean;
      isServiceUnit : Boolean;
      isBusinessUnit : Boolean;
      @title : 'Currency'
      currency : String(3);
      @title : 'Currency'
      currencyDescription : String(50);
    };
    nameAndAddress : many {
      @title : 'Technical ID'
      id : UUID;
      validFrom : Date;
      validTo : Date;
      @title : 'Name'
      name : String(40);
      @title : 'Address Technical ID'
      addressId : UUID;
      @title : 'Country/Region'
      country : String(3);
      @title : 'Country/Region'
      countryDescription : String(255);
      region : {
        @title : 'Country/Region'
        country : String(3);
        @title : 'State'
        region : String(6);
      };
      @title : 'State'
      regionDescription : String(255);
      @title : 'City'
      cityName : String(40);
      @title : 'Street'
      streetName : String(80);
      @title : 'House Number'
      houseId : String(10);
      @title : 'Postal Code'
      postalCode : String(10);
      @title : 'County'
      countyName : String(40);
      @title : 'District'
      districtName : String(40);
      @title : 'Address Line 1'
      streetPrefixName : String(40);
      @title : 'Address Line 2'
      additionalStreetPrefixName : String(40);
      @title : 'Address Line 4'
      streetSuffixName : String(40);
      @title : 'Address Line 5'
      additionalStreetSuffixName : String(40);
      @title : 'Address'
      formattedPostalAddressDescription : String(255);
      latitudeMeasure : Decimal;
      longitudeMeasure : Decimal;
      @title : 'Email'
      eMail : String(255);
      @title : 'Website'
      web : String(1280);
      @title : 'Fax'
      facsimileFormattedNumber : String(40);
      @title : 'Phone'
      phoneFormattedNumber : String(40);
      @title : 'Normalized Phone'
      phoneNormalisedNumber : String(40);
      @title : 'Mobile'
      mobileFormattedNumber : String(40);
      @title : 'Normalized Mobile'
      mobileNormalisedNumber : String(40);
    };
    parentOrganizationalUnitAssignments : many {
      @title : 'Technical ID'
      id : UUID;
      validFrom : Date;
      validTo : Date;
      @title : 'Parent Unit Technical ID'
      parentOrganizationalUnitId : UUID;
      @title : 'Parent Unit ID'
      parentOrganizationalUnitDisplayId : String(50);
      isReportingLine : Boolean;
    };
    salesAreas : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Distribution Channel'
      distributionChannel : String(2);
      @title : 'Distribution Channel'
      distributionChannelDescription : String(255);
      @title : 'Division'
      division : String(2);
      @title : 'Division'
      divisionDescription : String(255);
      allDistributionChannels : Boolean;
      allDivisions : Boolean;
    };
    externalIds : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'External ID'
      externalId : String(100);
      @title : 'Technical ID of Communication System'
      communicationSystemId : UUID;
      @title : 'Communication System ID'
      communicationSystemDisplayId : String(255);
      @title : 'ID Type'
      type : String(15);
      isDefault : Boolean;
    };
  };
};

@title : 'OrganizationalUnit file'
type Service_types.OrganizationalUnitfile {
  value : {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    adminData : {
      createdOn : Timestamp;
      @title : 'Created By'
      createdBy : UUID;
      @title : 'Created By Name'
      createdByName : String(255);
      updatedOn : Timestamp;
      @title : 'Changed By'
      updatedBy : UUID;
      @title : 'Changed By Name'
      updatedByName : String(255);
    };
    @title : 'Organizational Unit ID'
    displayId : String(50);
    @title : 'Name'
    name : String(40);
    @title : 'Status'
    lifeCycleStatus : String(14);
    @title : 'Status'
    lifeCycleStatusDescription : String(50);
    currentFunctions : {
      isCompany : Boolean;
      isSalesOrganization : Boolean;
      isServiceOrganization : Boolean;
      isSalesOffice : Boolean;
      isSalesGroup : Boolean;
      isSalesUnit : Boolean;
      isServiceUnit : Boolean;
      isBusinessUnit : Boolean;
      @title : 'Currency'
      currency : String(3);
      @title : 'Currency'
      currencyDescription : String(50);
    };
    reportingLineManager : {
      @title : 'Manager Technical ID'
      id : UUID;
      @title : 'Manager ID'
      displayId : String(10);
      @title : 'Manager Name'
      name : String(255);
    };
    reportingLineParentOrganizationalUnit : {
      @title : 'Parent Unit Technical ID'
      id : UUID;
      @title : 'Parent Unit ID'
      displayId : String(50);
      @title : 'Parent Unit Name'
      name : String(40);
    };
    address : {
      @title : 'Country/Region'
      country : String(3);
      @title : 'Country/Region'
      countryDescription : String(255);
      region : {
        @title : 'State'
        country : String(3);
        @title : 'State'
        region : String(6);
      };
      @title : 'State'
      regionDescription : String(255);
      @title : 'Postal Code'
      postalCode : String(10);
      @title : 'City'
      cityName : String(40);
      @title : 'Street'
      streetName : String(80);
      @title : 'House Number'
      houseId : String(10);
      @title : 'County'
      countyName : String(40);
      @title : 'District'
      districtName : String(40);
      @title : 'Address Line 1'
      streetPrefixName : String(40);
      @title : 'Address Line 2'
      additionalStreetPrefixName : String(40);
      @title : 'Address Line 4'
      streetSuffixName : String(40);
      @title : 'Address Line 5'
      additionalStreetSuffixName : String(40);
      latitudeMeasure : Decimal;
      longitudeMeasure : Decimal;
      @title : 'Address'
      formattedPostalAddressDescription : String(255);
    };
    communication : {
      @title : 'Email'
      eMail : String(255);
      @title : 'Website'
      web : String(1280);
      @title : 'Fax'
      facsimileFormattedNumber : String(40);
      @title : 'Phone'
      phoneFormattedNumber : String(40);
      @title : 'Normalized Phone'
      phoneNormalisedNumber : String(40);
      @title : 'Mobile'
      mobileFormattedNumber : String(40);
      @title : 'Normalized Mobile'
      mobileNormalisedNumber : String(40);
    };
    employeeAssignments : many {
      @title : 'Technical ID'
      id : UUID;
      validFrom : Date;
      validTo : Date;
      @title : 'Employee Technical ID'
      employeeId : UUID;
      employeeDisplayId : String(10);
      @title : 'Employee Name'
      employeeName : String(255);
      @title : 'Role'
      role : String(10);
      @title : 'Role'
      roleDescription : String(50);
    };
    functions : many {
      @title : 'Technical ID'
      id : UUID;
      validFrom : Date;
      validTo : Date;
      isCompany : Boolean;
      isSalesOrganization : Boolean;
      isServiceOrganization : Boolean;
      isSalesOffice : Boolean;
      isSalesGroup : Boolean;
      isSalesUnit : Boolean;
      isServiceUnit : Boolean;
      isBusinessUnit : Boolean;
      @title : 'Currency'
      currency : String(3);
      @title : 'Currency'
      currencyDescription : String(50);
    };
    nameAndAddress : many {
      @title : 'Technical ID'
      id : UUID;
      validFrom : Date;
      validTo : Date;
      @title : 'Name'
      name : String(40);
      @title : 'Address Technical ID'
      addressId : UUID;
      @title : 'Country/Region'
      country : String(3);
      @title : 'Country/Region'
      countryDescription : String(255);
      region : {
        @title : 'Country/Region'
        country : String(3);
        @title : 'State'
        region : String(6);
      };
      @title : 'State'
      regionDescription : String(255);
      @title : 'City'
      cityName : String(40);
      @title : 'Street'
      streetName : String(80);
      @title : 'House Number'
      houseId : String(10);
      @title : 'Postal Code'
      postalCode : String(10);
      @title : 'County'
      countyName : String(40);
      @title : 'District'
      districtName : String(40);
      @title : 'Address Line 1'
      streetPrefixName : String(40);
      @title : 'Address Line 2'
      additionalStreetPrefixName : String(40);
      @title : 'Address Line 4'
      streetSuffixName : String(40);
      @title : 'Address Line 5'
      additionalStreetSuffixName : String(40);
      @title : 'Address'
      formattedPostalAddressDescription : String(255);
      latitudeMeasure : Decimal;
      longitudeMeasure : Decimal;
      @title : 'Email'
      eMail : String(255);
      @title : 'Website'
      web : String(1280);
      @title : 'Fax'
      facsimileFormattedNumber : String(40);
      @title : 'Phone'
      phoneFormattedNumber : String(40);
      @title : 'Normalized Phone'
      phoneNormalisedNumber : String(40);
      @title : 'Mobile'
      mobileFormattedNumber : String(40);
      @title : 'Normalized Mobile'
      mobileNormalisedNumber : String(40);
    };
    parentOrganizationalUnitAssignments : many {
      @title : 'Technical ID'
      id : UUID;
      validFrom : Date;
      validTo : Date;
      @title : 'Parent Unit Technical ID'
      parentOrganizationalUnitId : UUID;
      @title : 'Parent Unit ID'
      parentOrganizationalUnitDisplayId : String(50);
      isReportingLine : Boolean;
    };
    salesAreas : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Distribution Channel'
      distributionChannel : String(2);
      @title : 'Distribution Channel'
      distributionChannelDescription : String(255);
      @title : 'Division'
      division : String(2);
      @title : 'Division'
      divisionDescription : String(255);
      allDistributionChannels : Boolean;
      allDivisions : Boolean;
    };
    externalIds : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'External ID'
      externalId : String(100);
      @title : 'Technical ID of Communication System'
      communicationSystemId : UUID;
      @title : 'Communication System ID'
      communicationSystemDisplayId : String(255);
      @title : 'ID Type'
      type : String(15);
      isDefault : Boolean;
    };
  };
};

@title : 'OrganizationalUnit create request'
type Service_types.OrganizationalUnitcreaterequest {
  @title : 'Technical ID'
  id : UUID;
  validFrom : Date;
  validTo : Date;
  adminData : {
    createdOn : Timestamp;
    @title : 'Created By'
    createdBy : UUID;
    @title : 'Created By Name'
    createdByName : String(255);
    updatedOn : Timestamp;
    @title : 'Changed By'
    updatedBy : UUID;
    @title : 'Changed By Name'
    updatedByName : String(255);
  };
  @title : 'Organizational Unit ID'
  displayId : String(50);
  @title : 'Name'
  name : String(40);
  @title : 'Status'
  lifeCycleStatus : String(14);
  currentFunctions : {
    isCompany : Boolean;
    isSalesOrganization : Boolean;
    isServiceOrganization : Boolean;
    isSalesOffice : Boolean;
    isSalesGroup : Boolean;
    isSalesUnit : Boolean;
    isServiceUnit : Boolean;
    isBusinessUnit : Boolean;
    @title : 'Currency'
    currency : String(3);
    @title : 'Currency'
    currencyDescription : String(50);
  };
  reportingLineManager : {
    @title : 'Manager Technical ID'
    id : UUID;
    @title : 'Manager ID'
    displayId : String(10);
    @title : 'Manager Name'
    name : String(255);
  };
  reportingLineParentOrganizationalUnit : {
    @title : 'Parent Unit Technical ID'
    id : UUID;
    @title : 'Parent Unit ID'
    displayId : String(50);
    @title : 'Parent Unit Name'
    name : String(40);
  };
  address : {
    @title : 'Country/Region'
    country : String(3);
    @title : 'Country/Region'
    countryDescription : String(255);
    region : {
      @title : 'State'
      country : String(3);
      @title : 'State'
      region : String(6);
    };
    @title : 'State'
    regionDescription : String(255);
    @title : 'Postal Code'
    postalCode : String(10);
    @title : 'City'
    cityName : String(40);
    @title : 'Street'
    streetName : String(80);
    @title : 'House Number'
    houseId : String(10);
    @title : 'County'
    countyName : String(40);
    @title : 'District'
    districtName : String(40);
    @title : 'Address Line 1'
    streetPrefixName : String(40);
    @title : 'Address Line 2'
    additionalStreetPrefixName : String(40);
    @title : 'Address Line 4'
    streetSuffixName : String(40);
    @title : 'Address Line 5'
    additionalStreetSuffixName : String(40);
    latitudeMeasure : Decimal;
    longitudeMeasure : Decimal;
    @title : 'Address'
    formattedPostalAddressDescription : String(255);
  };
  communication : {
    @title : 'Email'
    eMail : String(255);
    @title : 'Website'
    web : String(1280);
    @title : 'Fax'
    facsimileFormattedNumber : String(40);
    @title : 'Phone'
    phoneFormattedNumber : String(40);
    @title : 'Normalized Phone'
    phoneNormalisedNumber : String(40);
    @title : 'Mobile'
    mobileFormattedNumber : String(40);
    @title : 'Normalized Mobile'
    mobileNormalisedNumber : String(40);
  };
  employeeAssignments : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    @title : 'Employee Technical ID'
    employeeId : UUID;
    employeeDisplayId : String(10);
    @title : 'Employee Name'
    employeeName : String(255);
    @title : 'Role'
    role : String(10);
    @title : 'Role'
    roleDescription : String(50);
  };
  functions : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    isCompany : Boolean;
    isSalesOrganization : Boolean;
    isServiceOrganization : Boolean;
    isSalesOffice : Boolean;
    isSalesGroup : Boolean;
    isSalesUnit : Boolean;
    isServiceUnit : Boolean;
    isBusinessUnit : Boolean;
    @title : 'Currency'
    currency : String(3);
    @title : 'Currency'
    currencyDescription : String(50);
  };
  nameAndAddress : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    @title : 'Name'
    name : String(40);
    @title : 'Address Technical ID'
    addressId : UUID;
    @title : 'Country/Region'
    country : String(3);
    @title : 'Country/Region'
    countryDescription : String(255);
    region : {
      @title : 'Country/Region'
      country : String(3);
      @title : 'State'
      region : String(6);
    };
    @title : 'State'
    regionDescription : String(255);
    @title : 'City'
    cityName : String(40);
    @title : 'Street'
    streetName : String(80);
    @title : 'House Number'
    houseId : String(10);
    @title : 'Postal Code'
    postalCode : String(10);
    @title : 'County'
    countyName : String(40);
    @title : 'District'
    districtName : String(40);
    @title : 'Address Line 1'
    streetPrefixName : String(40);
    @title : 'Address Line 2'
    additionalStreetPrefixName : String(40);
    @title : 'Address Line 4'
    streetSuffixName : String(40);
    @title : 'Address Line 5'
    additionalStreetSuffixName : String(40);
    @title : 'Address'
    formattedPostalAddressDescription : String(255);
    latitudeMeasure : Decimal;
    longitudeMeasure : Decimal;
    @title : 'Email'
    eMail : String(255);
    @title : 'Website'
    web : String(1280);
    @title : 'Fax'
    facsimileFormattedNumber : String(40);
    @title : 'Phone'
    phoneFormattedNumber : String(40);
    @title : 'Normalized Phone'
    phoneNormalisedNumber : String(40);
    @title : 'Mobile'
    mobileFormattedNumber : String(40);
    @title : 'Normalized Mobile'
    mobileNormalisedNumber : String(40);
  };
  parentOrganizationalUnitAssignments : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    @title : 'Parent Unit Technical ID'
    parentOrganizationalUnitId : UUID;
    @title : 'Parent Unit ID'
    parentOrganizationalUnitDisplayId : String(50);
    isReportingLine : Boolean;
  };
  salesAreas : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Distribution Channel'
    distributionChannel : String(2);
    @title : 'Distribution Channel'
    distributionChannelDescription : String(255);
    @title : 'Division'
    division : String(2);
    @title : 'Division'
    divisionDescription : String(255);
    allDistributionChannels : Boolean;
    allDivisions : Boolean;
  };
  externalIds : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'External ID'
    externalId : String(100);
    @title : 'Technical ID of Communication System'
    communicationSystemId : UUID;
    @title : 'Communication System ID'
    communicationSystemDisplayId : String(255);
    @title : 'ID Type'
    type : String(15);
    isDefault : Boolean;
  };
};

@title : 'OrganizationalUnit update request'
type Service_types.OrganizationalUnitupdaterequest {
  validFrom : Date;
  validTo : Date;
  adminData : {
    createdOn : Timestamp;
    @title : 'Created By'
    createdBy : UUID;
    @title : 'Created By Name'
    createdByName : String(255);
    updatedOn : Timestamp;
    @title : 'Changed By'
    updatedBy : UUID;
    @title : 'Changed By Name'
    updatedByName : String(255);
  };
  @title : 'Name'
  name : String(40);
  @title : 'Status'
  lifeCycleStatus : String(14);
  currentFunctions : {
    isCompany : Boolean;
    isSalesOrganization : Boolean;
    isServiceOrganization : Boolean;
    isSalesOffice : Boolean;
    isSalesGroup : Boolean;
    isSalesUnit : Boolean;
    isServiceUnit : Boolean;
    isBusinessUnit : Boolean;
    @title : 'Currency'
    currency : String(3);
    @title : 'Currency'
    currencyDescription : String(50);
  };
  reportingLineManager : {
    @title : 'Manager Technical ID'
    id : UUID;
    @title : 'Manager ID'
    displayId : String(10);
    @title : 'Manager Name'
    name : String(255);
  };
  reportingLineParentOrganizationalUnit : {
    @title : 'Parent Unit Technical ID'
    id : UUID;
    @title : 'Parent Unit ID'
    displayId : String(50);
    @title : 'Parent Unit Name'
    name : String(40);
  };
  address : {
    @title : 'Country/Region'
    country : String(3);
    @title : 'Country/Region'
    countryDescription : String(255);
    region : {
      @title : 'State'
      country : String(3);
      @title : 'State'
      region : String(6);
    };
    @title : 'State'
    regionDescription : String(255);
    @title : 'Postal Code'
    postalCode : String(10);
    @title : 'City'
    cityName : String(40);
    @title : 'Street'
    streetName : String(80);
    @title : 'House Number'
    houseId : String(10);
    @title : 'County'
    countyName : String(40);
    @title : 'District'
    districtName : String(40);
    @title : 'Address Line 1'
    streetPrefixName : String(40);
    @title : 'Address Line 2'
    additionalStreetPrefixName : String(40);
    @title : 'Address Line 4'
    streetSuffixName : String(40);
    @title : 'Address Line 5'
    additionalStreetSuffixName : String(40);
    latitudeMeasure : Decimal;
    longitudeMeasure : Decimal;
    @title : 'Address'
    formattedPostalAddressDescription : String(255);
  };
  communication : {
    @title : 'Email'
    eMail : String(255);
    @title : 'Website'
    web : String(1280);
    @title : 'Fax'
    facsimileFormattedNumber : String(40);
    @title : 'Phone'
    phoneFormattedNumber : String(40);
    @title : 'Normalized Phone'
    phoneNormalisedNumber : String(40);
    @title : 'Mobile'
    mobileFormattedNumber : String(40);
    @title : 'Normalized Mobile'
    mobileNormalisedNumber : String(40);
  };
  employeeAssignments : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    @title : 'Employee Technical ID'
    employeeId : UUID;
    employeeDisplayId : String(10);
    @title : 'Employee Name'
    employeeName : String(255);
    @title : 'Role'
    role : String(10);
    @title : 'Role'
    roleDescription : String(50);
  };
  functions : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    isCompany : Boolean;
    isSalesOrganization : Boolean;
    isServiceOrganization : Boolean;
    isSalesOffice : Boolean;
    isSalesGroup : Boolean;
    isSalesUnit : Boolean;
    isServiceUnit : Boolean;
    isBusinessUnit : Boolean;
    @title : 'Currency'
    currency : String(3);
    @title : 'Currency'
    currencyDescription : String(50);
  };
  nameAndAddress : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    @title : 'Name'
    name : String(40);
    @title : 'Address Technical ID'
    addressId : UUID;
    @title : 'Country/Region'
    country : String(3);
    @title : 'Country/Region'
    countryDescription : String(255);
    region : {
      @title : 'Country/Region'
      country : String(3);
      @title : 'State'
      region : String(6);
    };
    @title : 'State'
    regionDescription : String(255);
    @title : 'City'
    cityName : String(40);
    @title : 'Street'
    streetName : String(80);
    @title : 'House Number'
    houseId : String(10);
    @title : 'Postal Code'
    postalCode : String(10);
    @title : 'County'
    countyName : String(40);
    @title : 'District'
    districtName : String(40);
    @title : 'Address Line 1'
    streetPrefixName : String(40);
    @title : 'Address Line 2'
    additionalStreetPrefixName : String(40);
    @title : 'Address Line 4'
    streetSuffixName : String(40);
    @title : 'Address Line 5'
    additionalStreetSuffixName : String(40);
    @title : 'Address'
    formattedPostalAddressDescription : String(255);
    latitudeMeasure : Decimal;
    longitudeMeasure : Decimal;
    @title : 'Email'
    eMail : String(255);
    @title : 'Website'
    web : String(1280);
    @title : 'Fax'
    facsimileFormattedNumber : String(40);
    @title : 'Phone'
    phoneFormattedNumber : String(40);
    @title : 'Normalized Phone'
    phoneNormalisedNumber : String(40);
    @title : 'Mobile'
    mobileFormattedNumber : String(40);
    @title : 'Normalized Mobile'
    mobileNormalisedNumber : String(40);
  };
  parentOrganizationalUnitAssignments : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    @title : 'Parent Unit Technical ID'
    parentOrganizationalUnitId : UUID;
    @title : 'Parent Unit ID'
    parentOrganizationalUnitDisplayId : String(50);
    isReportingLine : Boolean;
  };
  salesAreas : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Distribution Channel'
    distributionChannel : String(2);
    @title : 'Distribution Channel'
    distributionChannelDescription : String(255);
    @title : 'Division'
    division : String(2);
    @title : 'Division'
    divisionDescription : String(255);
    allDistributionChannels : Boolean;
    allDivisions : Boolean;
  };
  externalIds : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'External ID'
    externalId : String(100);
    @title : 'Technical ID of Communication System'
    communicationSystemId : UUID;
    @title : 'Communication System ID'
    communicationSystemDisplayId : String(255);
    @title : 'ID Type'
    type : String(15);
    isDefault : Boolean;
  };
};

@title : 'OrganizationalUnit patchupdate request'
type Service_types.OrganizationalUnitpatchupdaterequest {
  validFrom : Date;
  validTo : Date;
  adminData : {
    createdOn : Timestamp;
    @title : 'Created By'
    createdBy : UUID;
    @title : 'Created By Name'
    createdByName : String(255);
    updatedOn : Timestamp;
    @title : 'Changed By'
    updatedBy : UUID;
    @title : 'Changed By Name'
    updatedByName : String(255);
  };
  @title : 'Name'
  name : String(40);
  @title : 'Status'
  lifeCycleStatus : String(14);
  currentFunctions : {
    isCompany : Boolean;
    isSalesOrganization : Boolean;
    isServiceOrganization : Boolean;
    isSalesOffice : Boolean;
    isSalesGroup : Boolean;
    isSalesUnit : Boolean;
    isServiceUnit : Boolean;
    isBusinessUnit : Boolean;
    @title : 'Currency'
    currency : String(3);
    @title : 'Currency'
    currencyDescription : String(50);
  };
  reportingLineManager : {
    @title : 'Manager Technical ID'
    id : UUID;
    @title : 'Manager ID'
    displayId : String(10);
    @title : 'Manager Name'
    name : String(255);
  };
  reportingLineParentOrganizationalUnit : {
    @title : 'Parent Unit Technical ID'
    id : UUID;
    @title : 'Parent Unit ID'
    displayId : String(50);
    @title : 'Parent Unit Name'
    name : String(40);
  };
  address : {
    @title : 'Country/Region'
    country : String(3);
    @title : 'Country/Region'
    countryDescription : String(255);
    region : {
      @title : 'State'
      country : String(3);
      @title : 'State'
      region : String(6);
    };
    @title : 'State'
    regionDescription : String(255);
    @title : 'Postal Code'
    postalCode : String(10);
    @title : 'City'
    cityName : String(40);
    @title : 'Street'
    streetName : String(80);
    @title : 'House Number'
    houseId : String(10);
    @title : 'County'
    countyName : String(40);
    @title : 'District'
    districtName : String(40);
    @title : 'Address Line 1'
    streetPrefixName : String(40);
    @title : 'Address Line 2'
    additionalStreetPrefixName : String(40);
    @title : 'Address Line 4'
    streetSuffixName : String(40);
    @title : 'Address Line 5'
    additionalStreetSuffixName : String(40);
    latitudeMeasure : Decimal;
    longitudeMeasure : Decimal;
    @title : 'Address'
    formattedPostalAddressDescription : String(255);
  };
  communication : {
    @title : 'Email'
    eMail : String(255);
    @title : 'Website'
    web : String(1280);
    @title : 'Fax'
    facsimileFormattedNumber : String(40);
    @title : 'Phone'
    phoneFormattedNumber : String(40);
    @title : 'Normalized Phone'
    phoneNormalisedNumber : String(40);
    @title : 'Mobile'
    mobileFormattedNumber : String(40);
    @title : 'Normalized Mobile'
    mobileNormalisedNumber : String(40);
  };
  employeeAssignments : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    @title : 'Employee Technical ID'
    employeeId : UUID;
    employeeDisplayId : String(10);
    @title : 'Employee Name'
    employeeName : String(255);
    @title : 'Role'
    role : String(10);
    @title : 'Role'
    roleDescription : String(50);
  };
  functions : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    isCompany : Boolean;
    isSalesOrganization : Boolean;
    isServiceOrganization : Boolean;
    isSalesOffice : Boolean;
    isSalesGroup : Boolean;
    isSalesUnit : Boolean;
    isServiceUnit : Boolean;
    isBusinessUnit : Boolean;
    @title : 'Currency'
    currency : String(3);
    @title : 'Currency'
    currencyDescription : String(50);
  };
  nameAndAddress : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    @title : 'Name'
    name : String(40);
    @title : 'Address Technical ID'
    addressId : UUID;
    @title : 'Country/Region'
    country : String(3);
    @title : 'Country/Region'
    countryDescription : String(255);
    region : {
      @title : 'Country/Region'
      country : String(3);
      @title : 'State'
      region : String(6);
    };
    @title : 'State'
    regionDescription : String(255);
    @title : 'City'
    cityName : String(40);
    @title : 'Street'
    streetName : String(80);
    @title : 'House Number'
    houseId : String(10);
    @title : 'Postal Code'
    postalCode : String(10);
    @title : 'County'
    countyName : String(40);
    @title : 'District'
    districtName : String(40);
    @title : 'Address Line 1'
    streetPrefixName : String(40);
    @title : 'Address Line 2'
    additionalStreetPrefixName : String(40);
    @title : 'Address Line 4'
    streetSuffixName : String(40);
    @title : 'Address Line 5'
    additionalStreetSuffixName : String(40);
    @title : 'Address'
    formattedPostalAddressDescription : String(255);
    latitudeMeasure : Decimal;
    longitudeMeasure : Decimal;
    @title : 'Email'
    eMail : String(255);
    @title : 'Website'
    web : String(1280);
    @title : 'Fax'
    facsimileFormattedNumber : String(40);
    @title : 'Phone'
    phoneFormattedNumber : String(40);
    @title : 'Normalized Phone'
    phoneNormalisedNumber : String(40);
    @title : 'Mobile'
    mobileFormattedNumber : String(40);
    @title : 'Normalized Mobile'
    mobileNormalisedNumber : String(40);
  };
  parentOrganizationalUnitAssignments : many {
    @title : 'Technical ID'
    id : UUID;
    validFrom : Date;
    validTo : Date;
    @title : 'Parent Unit Technical ID'
    parentOrganizationalUnitId : UUID;
    @title : 'Parent Unit ID'
    parentOrganizationalUnitDisplayId : String(50);
    isReportingLine : Boolean;
  };
  salesAreas : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Distribution Channel'
    distributionChannel : String(2);
    @title : 'Distribution Channel'
    distributionChannelDescription : String(255);
    @title : 'Division'
    division : String(2);
    @title : 'Division'
    divisionDescription : String(255);
    allDistributionChannels : Boolean;
    allDivisions : Boolean;
  };
  externalIds : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'External ID'
    externalId : String(100);
    @title : 'Technical ID of Communication System'
    communicationSystemId : UUID;
    @title : 'Communication System ID'
    communicationSystemDisplayId : String(255);
    @title : 'ID Type'
    type : String(15);
    isDefault : Boolean;
  };
};

