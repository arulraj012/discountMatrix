sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"cust/discountapp/test/integration/pages/DiscountMatrixList",
	"cust/discountapp/test/integration/pages/DiscountMatrixObjectPage"
], function (JourneyRunner, DiscountMatrixList, DiscountMatrixObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('cust/discountapp') + '/test/flp.html#app-preview',
        pages: {
			onTheDiscountMatrixList: DiscountMatrixList,
			onTheDiscountMatrixObjectPage: DiscountMatrixObjectPage
        },
        async: true
    });

    return runner;
});

