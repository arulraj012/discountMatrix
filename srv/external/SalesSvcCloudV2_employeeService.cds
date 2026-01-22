/* checksum : 064c58166683b4e18c0778ae41395b5d */
namespace Employee;

@Capabilities.BatchSupported : false
@Capabilities.KeyAsSegmentSupported : true
@Core.Description : 'Employee Service'
@Core.SchemaVersion : '1.0.0'
@Core.LongDescription : 'Employee master data capabilities offer a holistic view of internal employees (a business partner person with valid employee type ''isInternalEmployee''). It allows you to maintain all relevant data for your internal employees such as basic data (name, workplace address, communication data), sales responsibility data, working hours information, and so on.'
service Service {
  @Common.Label : 'Employee'
  @Core.Description : 'Query employees in the system.'
  @Core.LongDescription : 'Specify query parameters to return desired employee records from the system.'
  @openapi.path : '/sap/c4c/api/v1/employee-service/employees'
  function sap_c4c_api_v1_employee_service_employees(
    @description : 'Skip the first n employees.'
    @openapi.in : 'query'
    @openapi.name : '$skip'
    _skip : Integer,
    @description : 'Show only the first n employees.'
    @openapi.in : 'query'
    @openapi.name : '$top'
    _top : Integer,
    @description : 'Search for a string within employees.'
    @openapi.in : 'query'
    @openapi.name : '$search'
    _search : String,
    @description : 'Filter employees by attribute.'
    @openapi.in : 'query'
    @openapi.name : '$filter'
    _filter : String,
    @description : 'Order employees by attribute.'
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
    @description : 'Indicates the count of employees to be returned.'
    @openapi.in : 'query'
    @openapi.name : '$count'
    _count : Boolean
  ) returns Service_types.Employeequeryresponse;

  @Common.Label : 'Employee'
  @Core.Description : 'Create a new employee.'
  @Core.LongDescription : 'Send employee information to the system to create a new employee.'
  @openapi.path : '/sap/c4c/api/v1/employee-service/employees'
  action sap_c4c_api_v1_employee_service_employees_post(
    @openapi.in : 'body'
    body : Service_types.Employeecreaterequest
  ) returns Service_types.Employeefile;

  @Common.Label : 'Employee'
  @Core.Description : 'Read employee information'
  @Core.LongDescription : 'Read a specific employee using the employee ID.'
  @openapi.path : '/sap/c4c/api/v1/employee-service/employees/{id}'
  function sap_c4c_api_v1_employee_service_employees_(
    @description : 'Employee ID'
    @openapi.in : 'path'
    id : UUID
  ) returns Service_types.Employeefile;

  @Common.Label : 'Employee'
  @Core.Description : 'Update or modify employee information.'
  @Core.LongDescription : 'Update employee attributes in the system.'
  @openapi.method : 'PATCH'
  @openapi.path : '/sap/c4c/api/v1/employee-service/employees/{id}'
  action sap_c4c_api_v1_employee_service_employees__patch(
    @description : 'Employee ID'
    @openapi.in : 'path'
    id : UUID,
    @openapi.contentType : 'application/merge-patch+json'
    @openapi.in : 'body'
    body : Service_types.Employeepatchupdaterequest
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

@title : 'Employee query response'
type Service_types.Employeequeryresponse {
  count : Integer;
  value : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Business Partner ID'
    displayId : String(10);
    @title : 'Employee ID'
    @mandatory : true
    employeeDisplayId : String(20);
    isInternalEmployee : Boolean;
    @title : 'Name'
    formattedName : String(255);
    @title : 'Status'
    lifeCycleStatus : String(14);
    @title : 'Status'
    lifeCycleStatusDescription : String(255);
    @title : 'Title'
    formOfAddress : String(4);
    @title : 'Title'
    formOfAddressDescription : String(255);
    @title : 'Academic Title'
    academicTitle : String(4);
    @title : 'Academic Title'
    academicTitleDescription : String(255);
    @title : 'First Name'
    givenName : String(40);
    @title : 'Middle Name'
    middleName : String(40);
    @title : 'Last Name'
    @mandatory : true
    familyName : String(40);
    @title : 'Additional Last Name'
    additionalFamilyName : String(40);
    @title : 'Initials'
    initialsName : String(10);
    @title : 'Nickname'
    nickName : String(40);
    @title : 'Gender'
    gender : String(1);
    @title : 'Gender'
    genderDescription : String(255);
    @title : 'Marital Status'
    maritalStatus : String(1);
    @title : 'Marital Status'
    maritalStatusDescription : String(255);
    @title : 'Language'
    nonVerbalCommunicationLanguage : String(5);
    @title : 'Language'
    nonVerbalCommunicationLanguageDescription : String(255);
    birthDate : Date;
    @title : 'Nationality'
    nationalityCountry : String(3);
    @title : 'Nationality'
    nationalityCountryDescription : String(255);
    @title : 'Default External Business Partner ID'
    defaultExternalBusinessPartnerId : String(100);
    @title : 'Default External Employee ID'
    defaultExternalEmployeeId : String(100);
    @title : 'Organizational Unit Technical ID'
    organizationalUnitId : UUID;
    @title : 'Organizational Unit ID'
    organizationalUnitDisplayId : String(50);
    @title : 'Organizational Unit Name'
    organizationalUnitName : String(40);
    @title : 'Manager Technical ID'
    managerId : UUID;
    @title : 'Manager ID'
    managerEmployeeDisplayId : String(20);
    @title : 'Manager Name'
    managerFormattedName : String(255);
    workplaceAddress : {
      @title : 'Street'
      streetName : String(80);
      @title : 'House Number'
      houseId : String(10);
      @title : 'City'
      cityName : String(40);
      @title : 'Postal Code'
      postalCode : String(10);
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
      @title : 'County'
      countyName : String(40);
      @title : 'District'
      districtName : String(40);
      latitudeMeasure : Decimal;
      longitudeMeasure : Decimal;
      @title : 'Building'
      buildingId : String(10);
      @title : 'Floor'
      floorId : String(10);
      @title : 'Room'
      roomId : String(10);
      @title : 'Phone'
      phoneFormattedNumber : String(40);
      @title : 'Normalized Phone'
      phoneNormalisedNumber : String(40);
      @title : 'Mobile'
      mobileFormattedNumber : String(40);
      @title : 'Normalized Mobile'
      mobileNormalisedNumber : String(40);
      @title : 'Email'
      eMail : String(255);
      @title : 'Address Line 1'
      streetPrefixName : String(40);
      @title : 'Address Line 2'
      additionalStreetPrefixName : String(40);
      @title : 'Address Line 4'
      streetSuffixName : String(40);
      @title : 'Address Line 5'
      additionalStreetSuffixName : String(40);
      @title : 'P.O. Box'
      postOfficeBoxId : String(10);
      isPostOfficeBoxAddress : Boolean;
      @title : 'Anubhav'
      formattedPostalAddressDescription : String(255);
      @title : 'Different City'
      additionalCityName : String(40);
      @title : 'Additional House Number'
      additionalHouseId : String(10);
      @title : 'C/O'
      careOfName : String(40);
    };
    isBusinessPurposeCompleted : Boolean;
    adminData : {
      createdOn : Timestamp;
      @title : 'Created By'
      createdBy : UUID;
      @title : 'Created By Name'
      createdByName : String;
      updatedOn : Timestamp;
      @title : 'Changed By'
      updatedBy : UUID;
      @title : 'Changed By Name'
      updatedByName : String;
    };
    employeeTypes : many {
      @title : 'Technical ID'
      id : UUID;
      isInternalEmployee : Boolean;
      validFrom : Date;
      validTo : Date;
    };
    workingHours : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Type'
      type : String(13);
      @title : 'Type'
      typeDescription : String(255);
      validFrom : Date;
      validTo : Date;
      @title : 'Time Zone'
      timeZone : String(10);
      @title : 'Time Zone'
      timeZoneDescription : String(255);
      @title : 'Working Day Calendar'
      workingDayCalendar : String(6);
      @title : 'Working Day Calendar'
      workingDayCalendarDescription : String(255);
      operatingPeriods : many {
        @title : 'Technical ID'
        id : UUID;
        @title : 'Weekday'
        weekday : String(9);
        startTime : Time;
        endTime : Time;
      };
    };
    employeeSalesResponsibilities : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Sales Organization Technical ID'
      salesOrganizationId : UUID;
      @title : 'Sales Organization ID'
      salesOrganizationDisplayId : String(50);
      @title : 'Sales Organization Name'
      salesOrganizationName : String(40);
      @title : 'Distribution Channel'
      distributionChannel : String(2);
      @title : 'Distribution Channel'
      distributionChannelDescription : String(50);
      @title : 'Division'
      division : String(2);
      @title : 'Division'
      divisionDescription : String(50);
      isDefault : Boolean;
    };
    attachments : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Title'
      title : String;
      @title : 'Type'
      type : String;
      @title : 'Category'
      category : String;
      fileSize : Decimal;
      @title : 'File Name'
      fileName : String;
      @title : 'Content Type'
      contentType : String;
      @title : 'URL'
      url : String;
    };
    externalIds : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'External ID'
      externalId : String(100);
      @title : 'Business System Technical ID'
      communicationSystemId : UUID;
      @title : 'Business System ID'
      communicationSystemDisplayId : String;
      @title : 'ID Type'
      type : String(15);
      isDefault : Boolean;
    };
  };
};

@title : 'Employee file'
type Service_types.Employeefile {
  value : {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Business Partner ID'
    displayId : String(10);
    @title : 'Employee ID'
    @mandatory : true
    employeeDisplayId : String(20);
    isInternalEmployee : Boolean;
    @title : 'Name'
    formattedName : String(255);
    @title : 'Status'
    lifeCycleStatus : String(14);
    @title : 'Status'
    lifeCycleStatusDescription : String(255);
    @title : 'Title'
    formOfAddress : String(4);
    @title : 'Title'
    formOfAddressDescription : String(255);
    @title : 'Academic Title'
    academicTitle : String(4);
    @title : 'Academic Title'
    academicTitleDescription : String(255);
    @title : 'First Name'
    givenName : String(40);
    @title : 'Middle Name'
    middleName : String(40);
    @title : 'Last Name'
    @mandatory : true
    familyName : String(40);
    @title : 'Additional Last Name'
    additionalFamilyName : String(40);
    @title : 'Initials'
    initialsName : String(10);
    @title : 'Nickname'
    nickName : String(40);
    @title : 'Gender'
    gender : String(1);
    @title : 'Gender'
    genderDescription : String(255);
    @title : 'Marital Status'
    maritalStatus : String(1);
    @title : 'Marital Status'
    maritalStatusDescription : String(255);
    @title : 'Language'
    nonVerbalCommunicationLanguage : String(5);
    @title : 'Language'
    nonVerbalCommunicationLanguageDescription : String(255);
    birthDate : Date;
    @title : 'Nationality'
    nationalityCountry : String(3);
    @title : 'Nationality'
    nationalityCountryDescription : String(255);
    @title : 'Default External Business Partner ID'
    defaultExternalBusinessPartnerId : String(100);
    @title : 'Default External Employee ID'
    defaultExternalEmployeeId : String(100);
    @title : 'Organizational Unit Technical ID'
    organizationalUnitId : UUID;
    @title : 'Organizational Unit ID'
    organizationalUnitDisplayId : String(50);
    @title : 'Organizational Unit Name'
    organizationalUnitName : String(40);
    @title : 'Manager Technical ID'
    managerId : UUID;
    @title : 'Manager ID'
    managerEmployeeDisplayId : String(20);
    @title : 'Manager Name'
    managerFormattedName : String(255);
    workplaceAddress : {
      @title : 'Street'
      streetName : String(80);
      @title : 'House Number'
      houseId : String(10);
      @title : 'City'
      cityName : String(40);
      @title : 'Postal Code'
      postalCode : String(10);
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
      @title : 'County'
      countyName : String(40);
      @title : 'District'
      districtName : String(40);
      latitudeMeasure : Decimal;
      longitudeMeasure : Decimal;
      @title : 'Building'
      buildingId : String(10);
      @title : 'Floor'
      floorId : String(10);
      @title : 'Room'
      roomId : String(10);
      @title : 'Phone'
      phoneFormattedNumber : String(40);
      @title : 'Normalized Phone'
      phoneNormalisedNumber : String(40);
      @title : 'Mobile'
      mobileFormattedNumber : String(40);
      @title : 'Normalized Mobile'
      mobileNormalisedNumber : String(40);
      @title : 'Email'
      eMail : String(255);
      @title : 'Address Line 1'
      streetPrefixName : String(40);
      @title : 'Address Line 2'
      additionalStreetPrefixName : String(40);
      @title : 'Address Line 4'
      streetSuffixName : String(40);
      @title : 'Address Line 5'
      additionalStreetSuffixName : String(40);
      @title : 'P.O. Box'
      postOfficeBoxId : String(10);
      isPostOfficeBoxAddress : Boolean;
      @title : 'Anubhav'
      formattedPostalAddressDescription : String(255);
      @title : 'Different City'
      additionalCityName : String(40);
      @title : 'Additional House Number'
      additionalHouseId : String(10);
      @title : 'C/O'
      careOfName : String(40);
    };
    isBusinessPurposeCompleted : Boolean;
    adminData : {
      createdOn : Timestamp;
      @title : 'Created By'
      createdBy : UUID;
      @title : 'Created By Name'
      createdByName : String;
      updatedOn : Timestamp;
      @title : 'Changed By'
      updatedBy : UUID;
      @title : 'Changed By Name'
      updatedByName : String;
    };
    employeeTypes : many {
      @title : 'Technical ID'
      id : UUID;
      isInternalEmployee : Boolean;
      validFrom : Date;
      validTo : Date;
    };
    workingHours : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Type'
      type : String(13);
      @title : 'Type'
      typeDescription : String(255);
      validFrom : Date;
      validTo : Date;
      @title : 'Time Zone'
      timeZone : String(10);
      @title : 'Time Zone'
      timeZoneDescription : String(255);
      @title : 'Working Day Calendar'
      workingDayCalendar : String(6);
      @title : 'Working Day Calendar'
      workingDayCalendarDescription : String(255);
      operatingPeriods : many {
        @title : 'Technical ID'
        id : UUID;
        @title : 'Weekday'
        weekday : String(9);
        startTime : Time;
        endTime : Time;
      };
    };
    employeeSalesResponsibilities : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Sales Organization Technical ID'
      salesOrganizationId : UUID;
      @title : 'Sales Organization ID'
      salesOrganizationDisplayId : String(50);
      @title : 'Sales Organization Name'
      salesOrganizationName : String(40);
      @title : 'Distribution Channel'
      distributionChannel : String(2);
      @title : 'Distribution Channel'
      distributionChannelDescription : String(50);
      @title : 'Division'
      division : String(2);
      @title : 'Division'
      divisionDescription : String(50);
      isDefault : Boolean;
    };
    attachments : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Title'
      title : String;
      @title : 'Type'
      type : String;
      @title : 'Category'
      category : String;
      fileSize : Decimal;
      @title : 'File Name'
      fileName : String;
      @title : 'Content Type'
      contentType : String;
      @title : 'URL'
      url : String;
    };
    externalIds : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'External ID'
      externalId : String(100);
      @title : 'Business System Technical ID'
      communicationSystemId : UUID;
      @title : 'Business System ID'
      communicationSystemDisplayId : String;
      @title : 'ID Type'
      type : String(15);
      isDefault : Boolean;
    };
  };
};

@title : 'Employee create request'
type Service_types.Employeecreaterequest {
  @title : 'Technical ID'
  id : UUID;
  @title : 'Business Partner ID'
  displayId : String(10);
  @title : 'Employee ID'
  @mandatory : true
  employeeDisplayId : String(20);
  @title : 'Title'
  formOfAddress : String(4);
  @title : 'Academic Title'
  academicTitle : String(4);
  @title : 'First Name'
  givenName : String(40);
  @title : 'Middle Name'
  middleName : String(40);
  @title : 'Last Name'
  @mandatory : true
  familyName : String(40);
  @title : 'Additional Last Name'
  additionalFamilyName : String(40);
  @title : 'Initials'
  initialsName : String(10);
  @title : 'Nickname'
  nickName : String(40);
  @title : 'Gender'
  gender : String(1);
  @title : 'Marital Status'
  maritalStatus : String(1);
  @title : 'Language'
  nonVerbalCommunicationLanguage : String(5);
  birthDate : Date;
  @title : 'Nationality'
  nationalityCountry : String(3);
  workplaceAddress : {
    @title : 'Street'
    streetName : String(80);
    @title : 'House Number'
    houseId : String(10);
    @title : 'City'
    cityName : String(40);
    @title : 'Postal Code'
    postalCode : String(10);
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
    @title : 'County'
    countyName : String(40);
    @title : 'District'
    districtName : String(40);
    latitudeMeasure : Decimal;
    longitudeMeasure : Decimal;
    @title : 'Building'
    buildingId : String(10);
    @title : 'Floor'
    floorId : String(10);
    @title : 'Room'
    roomId : String(10);
    @title : 'Phone'
    phoneFormattedNumber : String(40);
    @title : 'Normalized Phone'
    phoneNormalisedNumber : String(40);
    @title : 'Mobile'
    mobileFormattedNumber : String(40);
    @title : 'Normalized Mobile'
    mobileNormalisedNumber : String(40);
    @title : 'Email'
    eMail : String(255);
    @title : 'Address Line 1'
    streetPrefixName : String(40);
    @title : 'Address Line 2'
    additionalStreetPrefixName : String(40);
    @title : 'Address Line 4'
    streetSuffixName : String(40);
    @title : 'Address Line 5'
    additionalStreetSuffixName : String(40);
    @title : 'P.O. Box'
    postOfficeBoxId : String(10);
    isPostOfficeBoxAddress : Boolean;
    @title : 'Anubhav'
    formattedPostalAddressDescription : String(255);
    @title : 'Different City'
    additionalCityName : String(40);
    @title : 'Additional House Number'
    additionalHouseId : String(10);
    @title : 'C/O'
    careOfName : String(40);
  };
  employeeTypes : many {
    @title : 'Technical ID'
    id : UUID;
    isInternalEmployee : Boolean;
    validFrom : Date;
    validTo : Date;
  };
  workingHours : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Type'
    type : String(13);
    @title : 'Type'
    typeDescription : String(255);
    validFrom : Date;
    validTo : Date;
    @title : 'Time Zone'
    timeZone : String(10);
    @title : 'Time Zone'
    timeZoneDescription : String(255);
    @title : 'Working Day Calendar'
    workingDayCalendar : String(6);
    @title : 'Working Day Calendar'
    workingDayCalendarDescription : String(255);
    operatingPeriods : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Weekday'
      weekday : String(9);
      startTime : Time;
      endTime : Time;
    };
  };
  employeeSalesResponsibilities : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Sales Organization Technical ID'
    salesOrganizationId : UUID;
    @title : 'Sales Organization ID'
    salesOrganizationDisplayId : String(50);
    @title : 'Sales Organization Name'
    salesOrganizationName : String(40);
    @title : 'Distribution Channel'
    distributionChannel : String(2);
    @title : 'Distribution Channel'
    distributionChannelDescription : String(50);
    @title : 'Division'
    division : String(2);
    @title : 'Division'
    divisionDescription : String(50);
    isDefault : Boolean;
  };
  externalIds : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'External ID'
    externalId : String(100);
    @title : 'Business System Technical ID'
    communicationSystemId : UUID;
    @title : 'Business System ID'
    communicationSystemDisplayId : String;
    @title : 'ID Type'
    type : String(15);
    isDefault : Boolean;
  };
};

@title : 'Employee patchupdate request'
type Service_types.Employeepatchupdaterequest {
  @title : 'Title'
  formOfAddress : String(4);
  @title : 'Academic Title'
  academicTitle : String(4);
  @title : 'First Name'
  givenName : String(40);
  @title : 'Middle Name'
  middleName : String(40);
  @title : 'Last Name'
  familyName : String(40);
  @title : 'Additional Last Name'
  additionalFamilyName : String(40);
  @title : 'Initials'
  initialsName : String(10);
  @title : 'Nickname'
  nickName : String(40);
  @title : 'Gender'
  gender : String(1);
  @title : 'Marital Status'
  maritalStatus : String(1);
  @title : 'Language'
  nonVerbalCommunicationLanguage : String(5);
  birthDate : Date;
  @title : 'Nationality'
  nationalityCountry : String(3);
  workplaceAddress : {
    @title : 'Street'
    streetName : String(80);
    @title : 'House Number'
    houseId : String(10);
    @title : 'City'
    cityName : String(40);
    @title : 'Postal Code'
    postalCode : String(10);
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
    @title : 'County'
    countyName : String(40);
    @title : 'District'
    districtName : String(40);
    latitudeMeasure : Decimal;
    longitudeMeasure : Decimal;
    @title : 'Building'
    buildingId : String(10);
    @title : 'Floor'
    floorId : String(10);
    @title : 'Room'
    roomId : String(10);
    @title : 'Phone'
    phoneFormattedNumber : String(40);
    @title : 'Normalized Phone'
    phoneNormalisedNumber : String(40);
    @title : 'Mobile'
    mobileFormattedNumber : String(40);
    @title : 'Normalized Mobile'
    mobileNormalisedNumber : String(40);
    @title : 'Email'
    eMail : String(255);
    @title : 'Address Line 1'
    streetPrefixName : String(40);
    @title : 'Address Line 2'
    additionalStreetPrefixName : String(40);
    @title : 'Address Line 4'
    streetSuffixName : String(40);
    @title : 'Address Line 5'
    additionalStreetSuffixName : String(40);
    @title : 'P.O. Box'
    postOfficeBoxId : String(10);
    isPostOfficeBoxAddress : Boolean;
    @title : 'Anubhav'
    formattedPostalAddressDescription : String(255);
    @title : 'Different City'
    additionalCityName : String(40);
    @title : 'Additional House Number'
    additionalHouseId : String(10);
    @title : 'C/O'
    careOfName : String(40);
  };
  employeeTypes : many {
    @title : 'Technical ID'
    id : UUID;
    isInternalEmployee : Boolean;
    validFrom : Date;
    validTo : Date;
  };
  workingHours : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Type'
    type : String(13);
    @title : 'Type'
    typeDescription : String(255);
    validFrom : Date;
    validTo : Date;
    @title : 'Time Zone'
    timeZone : String(10);
    @title : 'Time Zone'
    timeZoneDescription : String(255);
    @title : 'Working Day Calendar'
    workingDayCalendar : String(6);
    @title : 'Working Day Calendar'
    workingDayCalendarDescription : String(255);
    operatingPeriods : many {
      @title : 'Technical ID'
      id : UUID;
      @title : 'Weekday'
      weekday : String(9);
      startTime : Time;
      endTime : Time;
    };
  };
  employeeSalesResponsibilities : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Sales Organization Technical ID'
    salesOrganizationId : UUID;
    @title : 'Sales Organization ID'
    salesOrganizationDisplayId : String(50);
    @title : 'Sales Organization Name'
    salesOrganizationName : String(40);
    @title : 'Distribution Channel'
    distributionChannel : String(2);
    @title : 'Distribution Channel'
    distributionChannelDescription : String(50);
    @title : 'Division'
    division : String(2);
    @title : 'Division'
    divisionDescription : String(50);
    isDefault : Boolean;
  };
  attachments : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'Title'
    title : String;
    @title : 'Type'
    type : String;
    @title : 'Category'
    category : String;
    fileSize : Decimal;
    @title : 'File Name'
    fileName : String;
    @title : 'Content Type'
    contentType : String;
    @title : 'URL'
    url : String;
  };
  externalIds : many {
    @title : 'Technical ID'
    id : UUID;
    @title : 'External ID'
    externalId : String(100);
    @title : 'Business System Technical ID'
    communicationSystemId : UUID;
    @title : 'Business System ID'
    communicationSystemDisplayId : String;
    @title : 'ID Type'
    type : String(15);
    isDefault : Boolean;
  };
};

