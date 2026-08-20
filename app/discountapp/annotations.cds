using DiscountMatrixSrv as service from '../../srv/discount-service';

// =====================================================
// BusinessUserRoles Entity Annotations
// =====================================================
annotate service.BusinessUserRoles with @(
    UI.HeaderInfo : {
        TypeName : 'Business User Role',
        TypeNamePlural : 'Business User Roles',
        Title : { Value : RoleCode }
    },
    UI.SelectionFields : [
        RoleCode,
        RoleName
    ],
    UI.LineItem : [
        { $Type : 'UI.DataField', Value : RoleCode, Label : 'Role Code' },
        { $Type : 'UI.DataField', Value : RoleName, Label : 'Role Name' }
    ],
    UI.FieldGroup #GeneralInfo : {
        $Type : 'UI.FieldGroupType',
        Data : [
            { $Type : 'UI.DataField', Value : RoleCode },
            { $Type : 'UI.DataField', Value : RoleName }
        ]
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneralInfoFacet',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneralInfo'
        }
    ],
    UI.PresentationVariant : {
        Visualizations : ['@UI.LineItem']
    }
);

annotate service.BusinessUserRoles with {
    RoleCode @Search.defaultSearchElement;
    RoleName @Search.defaultSearchElement;
};

// =====================================================
// ApproverPartyRoles Entity Annotations
// =====================================================
annotate service.ApproverPartyRoles with @(
    UI.HeaderInfo : {
        TypeName : 'Approver Party Role',
        TypeNamePlural : 'Approver Party Roles',
        Title : { Value : RoleCode }
    },
    UI.SelectionFields : [
        RoleCode,
        RoleName
    ],
    UI.LineItem : [
        { $Type : 'UI.DataField', Value : RoleCode, Label : 'Role Code' },
        { $Type : 'UI.DataField', Value : RoleName, Label : 'Role Name' }
    ],
    UI.FieldGroup #GeneralInfo : {
        $Type : 'UI.FieldGroupType',
        Data : [
            { $Type : 'UI.DataField', Value : RoleCode },
            { $Type : 'UI.DataField', Value : RoleName }
        ]
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneralInfoFacet',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneralInfo'
        }
    ],
    UI.PresentationVariant : {
        Visualizations : ['@UI.LineItem']
    }
);

annotate service.ApproverPartyRoles with {
    RoleCode @Search.defaultSearchElement;
    RoleName @Search.defaultSearchElement;
};

// =====================================================
// SalesOrganizations Entity Annotations
// =====================================================
annotate service.SalesOrganizations with @(
    UI.HeaderInfo : {
        TypeName : 'Sales Organization',
        TypeNamePlural : 'Sales Organizations',
        Title : { Value : SalesOrgCode }
    },
    UI.SelectionFields : [
        SalesOrgCode,
        SalesOrgName
    ],
    UI.LineItem : [
        { $Type : 'UI.DataField', Value : SalesOrgCode, Label : 'Sales Org Code' },
        { $Type : 'UI.DataField', Value : SalesOrgName, Label : 'Sales Org Name' }
    ],
    UI.FieldGroup #GeneralInfo : {
        $Type : 'UI.FieldGroupType',
        Data : [
            { $Type : 'UI.DataField', Value : SalesOrgCode },
            { $Type : 'UI.DataField', Value : SalesOrgName }
        ]
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneralInfoFacet',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneralInfo'
        }
    ],
    UI.PresentationVariant : {
        Visualizations : ['@UI.LineItem']
    }
);

annotate service.SalesOrganizations with {
    SalesOrgCode @Search.defaultSearchElement;
    SalesOrgName @Search.defaultSearchElement;
};

// =====================================================
// DistributionChannels Entity Annotations
// =====================================================
annotate service.DistributionChannels with @(
    UI.HeaderInfo : {
        TypeName : 'Distribution Channel',
        TypeNamePlural : 'Distribution Channels',
        Title : { Value : DistChannelCode }
    },
    UI.SelectionFields : [
        DistChannelCode,
        DistChannelName
    ],
    UI.LineItem : [
        { $Type : 'UI.DataField', Value : DistChannelCode, Label : 'Channel Code' },
        { $Type : 'UI.DataField', Value : DistChannelName, Label : 'Channel Name' }
    ],
    UI.FieldGroup #GeneralInfo : {
        $Type : 'UI.FieldGroupType',
        Data : [
            { $Type : 'UI.DataField', Value : DistChannelCode },
            { $Type : 'UI.DataField', Value : DistChannelName }
        ]
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneralInfoFacet',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneralInfo'
        }
    ],
    UI.PresentationVariant : {
        Visualizations : ['@UI.LineItem']
    }
);

annotate service.DistributionChannels with {
    DistChannelCode @Search.defaultSearchElement;
    DistChannelName @Search.defaultSearchElement;
};

// =====================================================
// Divisions Entity Annotations
// =====================================================
annotate service.Divisions with @(
    UI.HeaderInfo : {
        TypeName : 'Division',
        TypeNamePlural : 'Divisions',
        Title : { Value : DivisionCode }
    },
    UI.SelectionFields : [
        DivisionCode,
        DivisionName
    ],
    UI.LineItem : [
        { $Type : 'UI.DataField', Value : DivisionCode, Label : 'Division Code' },
        { $Type : 'UI.DataField', Value : DivisionName, Label : 'Division Name' }
    ],
    UI.FieldGroup #GeneralInfo : {
        $Type : 'UI.FieldGroupType',
        Data : [
            { $Type : 'UI.DataField', Value : DivisionCode },
            { $Type : 'UI.DataField', Value : DivisionName }
        ]
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneralInfoFacet',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneralInfo'
        }
    ],
    UI.PresentationVariant : {
        Visualizations : ['@UI.LineItem']
    }
);

annotate service.Divisions with {
    DivisionCode @Search.defaultSearchElement;
    DivisionName @Search.defaultSearchElement;
};

// =====================================================
// SalesOffices Entity Annotations
// =====================================================
annotate service.SalesOffices with @(
    UI.HeaderInfo : {
        TypeName : 'Sales Office',
        TypeNamePlural : 'Sales Offices',
        Title : { Value : SalesOfficeCode }
    },
    UI.SelectionFields : [
        SalesOfficeCode,
        SalesOfficeName
    ],
    UI.LineItem : [
        { $Type : 'UI.DataField', Value : SalesOfficeCode, Label : 'Sales Office Code' },
        { $Type : 'UI.DataField', Value : SalesOfficeName, Label : 'Sales Office Name' }
    ],
    UI.FieldGroup #GeneralInfo : {
        $Type : 'UI.FieldGroupType',
        Data : [
            { $Type : 'UI.DataField', Value : SalesOfficeCode },
            { $Type : 'UI.DataField', Value : SalesOfficeName }
        ]
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneralInfoFacet',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneralInfo'
        }
    ],
    UI.PresentationVariant : {
        Visualizations : ['@UI.LineItem']
    }
);

annotate service.SalesOffices with {
    SalesOfficeCode @Search.defaultSearchElement;
    SalesOfficeName @Search.defaultSearchElement;
};

// =====================================================
// Employees Entity Annotations
// =====================================================
annotate service.Employees with @(
    UI.HeaderInfo : {
        TypeName : 'Employee',
        TypeNamePlural : 'Employees',
        Title : { Value : EmployeeDisplayId }
    },
    UI.SelectionFields : [
        EmployeeDisplayId,
        EmployeeName
    ],
    UI.LineItem : [
        { $Type : 'UI.DataField', Value : EmployeeDisplayId, Label : 'Employee ID' },
        { $Type : 'UI.DataField', Value : EmployeeName, Label : 'Employee Name' }
    ],
    UI.FieldGroup #GeneralInfo : {
        $Type : 'UI.FieldGroupType',
        Data : [
            { $Type : 'UI.DataField', Value : EmployeeDisplayId },
            { $Type : 'UI.DataField', Value : EmployeeName }
        ]
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneralInfoFacet',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneralInfo'
        }
    ],
    UI.PresentationVariant : {
        Visualizations : ['@UI.LineItem']
    }
);

annotate service.Employees with {
    EmployeeId @Search.defaultSearchElement;
    EmployeeDisplayId @Search.defaultSearchElement;
    EmployeeName @Search.defaultSearchElement;
};

// =====================================================
// DiscountMatrix Entity Annotations
// =====================================================
annotate service.DiscountMatrix with @(
    Capabilities : {
        InsertRestrictions : {
            Insertable : true
        },
        UpdateRestrictions : {
            Updatable : true
        },
        DeleteRestrictions : {
            Deletable : true
        }
    }
);

annotate service.DiscountMatrix with @(
    UI.HeaderInfo : {
        TypeName : 'Discount Matrix',
        TypeNamePlural : 'Discount Matrix',
        Title : {
            $Type : 'UI.DataField',
            Value : combinedHeader
        },
        Description : {
            $Type : 'UI.DataField',
            Value : approverPartyRole
        }
    },
    UI.DeleteHidden : false,
    UI.UpdateHidden : false,
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : approvalLevel,
            },
            {
                $Type : 'UI.DataField',
                Value : salesOrg,
            },
            {
                $Type : 'UI.DataField',
                Value : distributionChannel,
            },
            {
                $Type : 'UI.DataField',
                Value : division,
            },
            {
                $Type : 'UI.DataField',
                Value : salesOffice,
            },
            {
                $Type : 'UI.DataField',
                Value : businessUserRole,
            },
            {
                $Type : 'UI.DataField',
                Value : approverPartyRole,
                
            },
            {
                $Type : 'UI.DataField',
                Value : approverEmployeeId,
            },
            {
                $Type : 'UI.DataField',
                Value : active,
            },
            {
                $Type : 'UI.DataField',
                Value : minPercentage,
            },
            {
                $Type : 'UI.DataField',
                Value : maxPercentage,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],
    UI.SelectionFields : [
        approvalLevel,
        salesOrg,
        distributionChannel,
        division,
        salesOffice,
        businessUserRole,
        approverPartyRole,
        approverEmployeeId,
        active
    ],
    UI.LineItem : [
        { $Type : 'UI.DataField', Value : approvalLevel },
        { $Type : 'UI.DataField', Value : salesOrg },
        { $Type : 'UI.DataField', Value : distributionChannel },
        { $Type : 'UI.DataField', Value : division },
        { $Type : 'UI.DataField', Value : salesOffice },
        { $Type : 'UI.DataField', Value : businessUserRole },
        { $Type : 'UI.DataField', Value : approverPartyRole },
        { $Type : 'UI.DataField', Value : approverEmployeeId },
        { $Type : 'UI.DataField', Value : active },
        { $Type : 'UI.DataField', Value : minPercentage },
        { $Type : 'UI.DataField', Value : maxPercentage }
    ],
    // Default sorting by salesOrg, distributionChannel, division (ascending)
    UI.PresentationVariant : {
        SortOrder : [
            {
                Property : salesOrg,
                Descending : false
            },
            {
                Property : distributionChannel,
                Descending : false
            },
            {
                Property : division,
                Descending : false
            }
        ],
        Visualizations : ['@UI.LineItem']
    }
);

annotate service.DiscountMatrix with {

    sequence              @Search.defaultSearchElement;
    approvalLevel         @Search.defaultSearchElement;
    salesOrg              @Search.defaultSearchElement;
    distributionChannel   @Search.defaultSearchElement;
    division              @Search.defaultSearchElement;
    salesOffice           @Search.defaultSearchElement;
    businessUserRole      @Search.defaultSearchElement;
    approverPartyRole     @Search.defaultSearchElement;
    approverEmployeeId    @Search.defaultSearchElement;

    // Value help for Sales Organization - fetched from Sales Cloud V2 API
    salesOrg @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'SalesOrganizations',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : salesOrg,
                    ValueListProperty : 'SalesOrgCode'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'SalesOrgName'
                }
            ]
        }
    );

    // Value help for Distribution Channel - fetched from Sales Cloud V2 API
    distributionChannel @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'DistributionChannels',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : distributionChannel,
                    ValueListProperty : 'DistChannelCode'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'DistChannelName'
                }
            ]
        }
    );

    // Value help for Division - fetched from Sales Cloud V2 API
    division @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Divisions',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : division,
                    ValueListProperty : 'DivisionCode'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'DivisionName'
                }
            ]
        }
    );

    // Value help for Sales Office - fetched from Sales Cloud V2 API
    salesOffice @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'SalesOffices',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : salesOffice,
                    ValueListProperty : 'SalesOfficeCode'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'SalesOfficeName'
                }
            ]
        }
    );

    // Text annotation for Business User Role - show description instead of code
    businessUserRole @(
        Common.Text : businessUserRoleRef.RoleName,
        Common.TextArrangement : #TextOnly,
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'BusinessUserRoles',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : businessUserRole,
                    ValueListProperty : 'RoleCode'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'RoleName'
                }
            ]
        },
        Common.ValueListWithFixedValues : true
    );

    // Text annotation for Approver Party Role - show description instead of code
    approverPartyRole @(
        Common.Text : approverPartyRoleRef.RoleName,
        Common.TextArrangement : #TextOnly,
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'ApproverPartyRoles',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : approverPartyRole,
                    ValueListProperty : 'RoleCode'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'RoleName'
                }
            ]
        },
        Common.ValueListWithFixedValues : true
    );

    // Value help for Approver Employee ID - fetched from Sales Cloud V2 Employee API
    approverEmployeeId @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Employees',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : approverEmployeeId,
                    ValueListProperty : 'EmployeeDisplayId'
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'EmployeeName'
                }
            ]
        }
    );
};
