using DiscountMatrixSrv as service from '../../srv/discount-service';
annotate service.DiscountMatrix with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : sequence,
            },
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
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : sequence,
        },
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
    ],
);

