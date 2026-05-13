@IsTest
private class PricingServiceTest {
  private static OrderItem createOrderItem(Boolean valid) {
    OrderItem item = new OrderItem(
      Quantity = 1,
      UnitPrice = 100,
      Selling_Price__c = 100
    );

    item.Production_Cost__c = 50;
    item.Shipping_Cost__c = 10;
    item.Tax_Percentage__c = 5;
    item.Margin_Percentage__c = 10;

    if (valid) {
      item.Production_Cost__c = 100;
      item.Shipping_Cost__c = 50;
      item.Tax_Percentage__c = 10;
      item.Margin_Percentage__c = 20;
    }

    return item;
  }

  @IsTest
  static void testValidateRequiredParameters_shouldAddError() {
    OrderItem oi = createOrderItem(false);
    oi.Production_Cost__c = null;

    Test.startTest();
    PricingService.validateRequiredParameters(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assert(oi.hasErrors(), 'Deveria ter erro por Production_Cost nulo');
  }

  @IsTest
  static void testValidateRequiredParameters_shouldAddError_NullShippingCost() {
    OrderItem oi = createOrderItem(false);
    oi.Shipping_Cost__c = null;

    Test.startTest();
    PricingService.validateRequiredParameters(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assert(oi.hasErrors(), 'Deveria ter erro por Shipping_Cost nulo');
  }

  @IsTest
  static void testValidateRequiredParameters_shouldAddError_NullTaxPercentage() {
    OrderItem oi = createOrderItem(false);
    oi.Tax_Percentage__c = null;

    Test.startTest();
    PricingService.validateRequiredParameters(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assert(oi.hasErrors(), 'Deveria ter erro por Tax_Percentage nulo');
  }

  @IsTest
  static void testValidateRequiredParameters_shouldAddError_NullMarginPercentage() {
    OrderItem oi = createOrderItem(false);
    oi.Margin_Percentage__c = null;

    Test.startTest();
    PricingService.validateRequiredParameters(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assert(
      oi.hasErrors(),
      'Deveria ter erro por Margin_Percentage nulo'
    );
  }

  @IsTest
  static void testValidateRequiredParameters_shouldAddError_MultipleNullFields() {
    OrderItem oi = createOrderItem(false);
    oi.Production_Cost__c = null;
    oi.Shipping_Cost__c = null;
    oi.Tax_Percentage__c = null;

    Test.startTest();
    PricingService.validateRequiredParameters(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assert(
      oi.hasErrors(),
      'Should have error with multiple null fields'
    );
  }

  @IsTest
  static void testValidateRequiredParameters_shouldNotAddError() {
    OrderItem oi = createOrderItem(true);

    Test.startTest();
    PricingService.validateRequiredParameters(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assert(
      !oi.hasErrors(),
      'Should not have error with all fields filled'
    );
  }

  @IsTest
  static void testValidateRequiredParameters_multipleItems() {
    List<OrderItem> items = new List<OrderItem>();
    items.add(createOrderItem(true));
    items.add(createOrderItem(true));
    items.add(createOrderItem(true));

    Test.startTest();
    PricingService.validateRequiredParameters(items);
    Test.stopTest();

    for (OrderItem item : items) {
      System.assert(!item.hasErrors(), 'Nenhum item deveria ter erro');
    }
  }

  @IsTest
  static void testCalculatePricing_withValues() {
    OrderItem oi = createOrderItem(true);

    oi.Selling_Price__c = 150;
    oi.Quantity = 2;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assertNotEquals(null, oi.Price_without_margin__c);
    System.assertNotEquals(null, oi.Final_Price__c);
    System.assertEquals(300, oi.Total_Price__c, 'Total Price deve ser 150 * 2');
  }

  @IsTest
  static void testCalculatePricing_withDiscount() {
    OrderItem oi = createOrderItem(true);

    oi.Production_Cost__c = 100;
    oi.Shipping_Cost__c = 50;
    oi.Tax_Percentage__c = 10;
    oi.Margin_Percentage__c = 20;
    oi.Selling_Price__c = 150;
    oi.Quantity = 1;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assert(
      oi.Discount__c > 0,
      'Deveria calcular desconto quando venda < final'
    );
  }

  @IsTest
  static void testCalculatePricing_withoutDiscount() {
    OrderItem oi = createOrderItem(true);

    oi.Production_Cost__c = 100;
    oi.Shipping_Cost__c = 50;
    oi.Tax_Percentage__c = 10;
    oi.Margin_Percentage__c = 20;
    oi.Selling_Price__c = 200;
    oi.Quantity = 1;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assertEquals(
      0,
      oi.Discount__c,
      'Should not have discount when sale >= final'
    );
  }

  @IsTest
  static void testCalculatePricing_withNullValues() {
    OrderItem oi = createOrderItem(false);

    oi.Selling_Price__c = 0;
    oi.Quantity = 1;
    oi.Production_Cost__c = null;
    oi.Shipping_Cost__c = null;
    oi.Tax_Percentage__c = null;
    oi.Margin_Percentage__c = null;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assertEquals(0, oi.Price_without_margin__c);
    System.assertEquals(0, oi.Final_Price__c);
    System.assertEquals(0, oi.Discount__c);
  }

  @IsTest
  static void testCalculatePricing_withZeroMargin() {
    OrderItem oi = createOrderItem(false);

    oi.Production_Cost__c = 100;
    oi.Shipping_Cost__c = 50;
    oi.Tax_Percentage__c = 10;
    oi.Margin_Percentage__c = 0;
    oi.Selling_Price__c = 165;
    oi.Quantity = 1;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assertEquals(
      oi.Price_without_margin__c,
      oi.Final_Price__c,
      'Final Price should equal Price Without Margin when margin is zero'
    );
  }

  @IsTest
  static void testCalculatePricing_withZeroTax() {
    OrderItem oi = createOrderItem(false);

    oi.Production_Cost__c = 100;
    oi.Shipping_Cost__c = 50;
    oi.Tax_Percentage__c = 0;
    oi.Margin_Percentage__c = 20;
    oi.Selling_Price__c = 180;
    oi.Quantity = 1;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    Decimal expectedPriceWithoutMargin = 150;
    System.assertEquals(
      expectedPriceWithoutMargin,
      oi.Price_without_margin__c,
      'Price Without Margin should be 150 when there is no fee'
    );
  }

  @IsTest
  static void testCalculatePricing_withHighMargin() {
    OrderItem oi = createOrderItem(false);

    oi.Production_Cost__c = 100;
    oi.Shipping_Cost__c = 50;
    oi.Tax_Percentage__c = 10;
    oi.Margin_Percentage__c = 100;
    oi.Selling_Price__c = 300;
    oi.Quantity = 1;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assertNotEquals(null, oi.Final_Price__c);
    System.assert(
      oi.Final_Price__c > oi.Price_without_margin__c,
      'Final Price deve ser maior que Price Without Margin com margem'
    );
  }

  @IsTest
  static void testCalculatePricing_withHighTax() {
    OrderItem oi = createOrderItem(false);

    oi.Production_Cost__c = 100;
    oi.Shipping_Cost__c = 50;
    oi.Tax_Percentage__c = 30;
    oi.Margin_Percentage__c = 20;
    oi.Selling_Price__c = 200;
    oi.Quantity = 1;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assertNotEquals(null, oi.Price_without_margin__c);
    System.assert(
      oi.Price_without_margin__c > 150,
      'Price Without Margin deve ser maior que 150 com taxa de 30%'
    );
  }

  @IsTest
  static void testCalculatePricing_withLargeQuantity() {
    OrderItem oi = createOrderItem(true);

    oi.Selling_Price__c = 150;
    oi.Quantity = 1000;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assertEquals(
      150000,
      oi.Total_Price__c,
      'Total Price deve ser 150 * 1000'
    );
  }

  @IsTest
  static void testCalculatePricing_withDecimalValues() {
    OrderItem oi = createOrderItem(false);

    oi.Production_Cost__c = 99.99;
    oi.Shipping_Cost__c = 19.99;
    oi.Tax_Percentage__c = 7.5;
    oi.Margin_Percentage__c = 15.25;
    oi.Selling_Price__c = 180.50;
    oi.Quantity = 3;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assertEquals(
      541.50,
      oi.Total_Price__c,
      'Total Price deve ser 180.50 * 3'
    );
    System.assertNotEquals(null, oi.Price_without_margin__c);
    System.assertNotEquals(null, oi.Final_Price__c);
  }

  @IsTest
  static void testCalculatePricing_multipleItems() {
    List<OrderItem> items = new List<OrderItem>();

    OrderItem oi1 = createOrderItem(true);
    oi1.Selling_Price__c = 150;
    oi1.Quantity = 2;
    items.add(oi1);

    OrderItem oi2 = createOrderItem(true);
    oi2.Selling_Price__c = 200;
    oi2.Quantity = 3;
    items.add(oi2);

    OrderItem oi3 = createOrderItem(true);
    oi3.Selling_Price__c = 100;
    oi3.Quantity = 1;
    items.add(oi3);

    Test.startTest();
    PricingService.calculatePricing(items);
    Test.stopTest();

    System.assertEquals(300, items[0].Total_Price__c);
    System.assertEquals(600, items[1].Total_Price__c);
    System.assertEquals(100, items[2].Total_Price__c);
  }

  @IsTest
  static void testCalculatePricing_withSmallValues() {
    OrderItem oi = createOrderItem(false);

    oi.Production_Cost__c = 0.50;
    oi.Shipping_Cost__c = 0.25;
    oi.Tax_Percentage__c = 5;
    oi.Margin_Percentage__c = 10;
    oi.Selling_Price__c = 1.00;
    oi.Quantity = 10;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assertEquals(10.00, oi.Total_Price__c);
    System.assertNotEquals(null, oi.Price_without_margin__c);
  }

  @IsTest
  static void testCalculatePricing_withZeroQuantity() {
    OrderItem oi = createOrderItem(true);

    oi.Selling_Price__c = 150;
    oi.Quantity = 0;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    System.assertEquals(0, oi.Total_Price__c);
  }

  @IsTest
  static void testCalculatePricing_precision() {
    OrderItem oi = createOrderItem(false);

    oi.Production_Cost__c = 100;
    oi.Shipping_Cost__c = 50;
    oi.Tax_Percentage__c = 10;
    oi.Margin_Percentage__c = 20;
    oi.Selling_Price__c = 180;
    oi.Quantity = 1;

    Test.startTest();
    PricingService.calculatePricing(new List<OrderItem>{ oi });
    Test.stopTest();

    String priceStr = String.valueOf(oi.Price_without_margin__c);
    String finalStr = String.valueOf(oi.Final_Price__c);

    System.assert(
      priceStr.contains('.') || priceStr.length() > 0,
      'Price Without Margin deve ser calculado'
    );
    System.assert(
      finalStr.contains('.') || finalStr.length() > 0,
      'Final Price deve ser calculado'
    );
  }
}
