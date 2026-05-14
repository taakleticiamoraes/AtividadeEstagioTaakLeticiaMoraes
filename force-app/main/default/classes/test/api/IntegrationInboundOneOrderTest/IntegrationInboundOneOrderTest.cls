@IsTest
public with sharing class IntegrationInboundOneOrderTest {
  @TestSetup
  public static void makeData() {
    Long timestamp = System.currentTimeMillis();

    TestFactorySObject.getInstance().createSObject(new City__c());

    City__c testCity = [
      SELECT Id, State__c, State__r.Country__c
      FROM City__c
      LIMIT 1
    ];

    Account acc = (Account) TestFactorySObject.getInstance()
      .createSObject(new Account());
    acc.Name = 'Test Client ' + timestamp;
    acc.ExternalId__c = 'ACC-TEST-' + timestamp;
    insert acc;

    Address__c address = (Address__c) TestFactorySObject.getInstance()
      .createSObject(new Address__c());
    address.Account__c = acc.Id;
    address.City__c = testCity.Id;
    address.CEP__c = '01310100';
    insert address;

    Distribution_Center__c dc = new Distribution_Center__c(
      Name = 'DC-TEST-' + timestamp
    );
    insert dc;

    Payment_Terms__c paymentTerms = new Payment_Terms__c(
      Name = 'NET-' + timestamp
    );
    insert paymentTerms;

    Contract contract = new Contract(
      AccountId = acc.Id,
      ExternalId__c = 'CONT-' + timestamp,
      StartDate = Date.today(),
      ContractTerm = 12,
      Status = 'Draft'
    );
    insert contract;

    contract.Status = 'Activated';
    update contract;

    Pricebook2 pricebook = new Pricebook2(
      Name = 'PB-' + timestamp,
      ExternalId__c = 'PB-' + timestamp,
      IsActive = true
    );
    insert pricebook;

    Product2 product = (Product2) TestFactorySObject.getInstance()
      .createSObject(new Product2());
    product.Name = 'Prod ' + timestamp;
    product.ExternalId__c = 'PROD-' + timestamp;
    insert product;

    PricebookEntry customPBE = new PricebookEntry(
      Pricebook2Id = pricebook.Id,
      Product2Id = product.Id,
      UnitPrice = 100,
      ExternalId__c = 'PBE-' + timestamp,
      IsActive = true
    );
    insert customPBE;

    Tax__c tax = (Tax__c) TestFactorySObject.getInstance()
      .createSObject(new Tax__c());
    tax.Product__c = product.Id;
    tax.Distribution_Center__c = dc.Id;
    tax.State__c = testCity.State__c;
    tax.Status__c = 'Approved';
    insert tax;

    Freight__c freight = (Freight__c) TestFactorySObject.getInstance()
      .createSObject(new Freight__c());
    freight.Product__c = product.Id;
    freight.Distribution_Center__c = dc.Id;
    freight.City__c = testCity.Id;
    freight.Status__c = 'Approved';
    insert freight;

    Margin__c margin = (Margin__c) TestFactorySObject.getInstance()
      .createSObject(new Margin__c());
    margin.Account__c = acc.Id;
    margin.Distribution_Center__c = dc.Id;
    margin.Value__c = 20;
    insert margin;

    Order order = (Order) TestFactorySObject.getInstance()
      .createSObject(new Order());
    order.ExternalId__c = 'TEST-ORDER-001';
    order.AccountId = acc.Id;
    order.Pricebook2Id = pricebook.Id;
    order.Address__c = address.Id;
    order.Distribution_Center__c = dc.Id;
    order.Payment_Terms__c = paymentTerms.Id;
    order.ContractId = contract.Id;
    insert order;

    OrderItem orderItem = new OrderItem(
      ExternalId__c = 'ITEM-DUMMY-001',
      OrderId = order.Id,
      PricebookEntryId = customPBE.Id,
      Quantity = 5,
      UnitPrice = 100,
      Selling_Price__c = 120,
      Production_Cost__c = 80,
      DeletedProduct__c = false
    );
    insert orderItem;
  }

  @IsTest
  public static void testUpsertOrderSuccess() {
    Account testAcc = [SELECT ExternalId__c FROM Account LIMIT 1];
    Pricebook2 testPb = [SELECT ExternalId__c FROM Pricebook2 LIMIT 1];
    Address__c testAddr = [SELECT CEP__c FROM Address__c LIMIT 1];
    Distribution_Center__c testDc = [
      SELECT Name
      FROM Distribution_Center__c
      LIMIT 1
    ];
    Payment_Terms__c testPt = [SELECT Name FROM Payment_Terms__c LIMIT 1];
    Contract testCont = [SELECT ExternalId__c FROM Contract LIMIT 1];
    PricebookEntry testPbe = [SELECT ExternalId__c FROM PricebookEntry LIMIT 1];

    DataIntegrationFields.OrderINData orderData = new DataIntegrationFields.OrderINData();
    orderData.externalId = 'TEST-ORDER-SUCCESS-ONE';
    orderData.status = 'Draft';
    orderData.effectiveDate = '2026-05-13';
    orderData.deliveryDate = '2026-05-20';
    orderData.accountExternalId = testAcc.ExternalId__c;
    orderData.pricebook2ExternalId = testPb.ExternalId__c;
    orderData.addressName = testAddr.CEP__c;
    orderData.distributionCenterName = testDc.Name;
    orderData.paymentTermsName = testPt.Name;
    orderData.contractExternalId = testCont.ExternalId__c;

    orderData.orderItemList = new List<DataIntegrationFields.OrderItemINData>();
    DataIntegrationFields.OrderItemINData itemData = new DataIntegrationFields.OrderItemINData();
    itemData.externalId = 'ITEM-SUCCESS-001';
    itemData.pricebookEntryExternalId = testPbe.ExternalId__c;
    itemData.quantity = 5;
    itemData.unitPrice = 100;
    itemData.sellingPrice = 120;
    itemData.productionCost = 80;
    orderData.orderItemList.add(itemData);

    Test.startTest();
    DataIntegrationFields.Response response = IntegrationInboundOneOrder.upsertOrder(
      orderData
    );
    Test.stopTest();

    System.assertNotEquals(null, response, 'The response should not be null');
  }

  @IsTest
  public static void testDeletedOrderItemLogical() {
    List<DataIntegrationFields.OrderItemINData> orderItemRequestList = new List<DataIntegrationFields.OrderItemINData>();

    DataIntegrationFields.OrderItemINData itemData = new DataIntegrationFields.OrderItemINData();
    itemData.externalId = 'DIFFERENT-FROM-DUMMY';
    itemData.orderExternalId = 'TEST-ORDER-001';
    orderItemRequestList.add(itemData);

    Test.startTest();
    Boolean hasDeletedLogical = IntegrationInboundOneOrder.deletedOrderItem(
      orderItemRequestList,
      false
    );
    Test.stopTest();

    System.assertEquals(
      true,
      hasDeletedLogical,
      'The setup item should have been logically updated'
    );

    OrderItem updatedItem = [
      SELECT DeletedProduct__c
      FROM OrderItem
      WHERE ExternalId__c = 'ITEM-DUMMY-001'
      LIMIT 1
    ];
    System.assertEquals(true, updatedItem.DeletedProduct__c);
  }

  @IsTest
  public static void testDeletedOrderItemPhysical() {
    List<DataIntegrationFields.OrderItemINData> orderItemRequestList = new List<DataIntegrationFields.OrderItemINData>();

    DataIntegrationFields.OrderItemINData itemData = new DataIntegrationFields.OrderItemINData();
    itemData.externalId = 'DIFFERENT-FROM-DUMMY';
    itemData.orderExternalId = 'TEST-ORDER-001';
    orderItemRequestList.add(itemData);

    Test.startTest();
    Boolean hasDeletedPhysical = IntegrationInboundOneOrder.deletedOrderItem(
      orderItemRequestList,
      true
    );
    Test.stopTest();

    System.assertEquals(
      true,
      hasDeletedPhysical,
      'The record should have been physically deleted'
    );

    List<OrderItem> currentItems = [
      SELECT Id
      FROM OrderItem
      WHERE ExternalId__c = 'ITEM-DUMMY-001'
    ];
    System.assertEquals(0, currentItems.size());
  }

  @IsTest
  public static void testFillResponseListAndErrors() {
    List<DataIntegrationFields.ResponseParent> orderResponseList = new List<DataIntegrationFields.ResponseParent>();
    Map<String, List<DataIntegrationFields.Response>> orderItemResponseList = new Map<String, List<DataIntegrationFields.Response>>();

    DataIntegrationFields.ResponseParent resParent1 = new DataIntegrationFields.ResponseParent();
    resParent1.externalId = 'EXT-001';
    resParent1.salesforceId = '001xx00000xxxx1AAA';
    resParent1.hasError = false;
    orderResponseList.add(resParent1);

    DataIntegrationFields.ResponseParent resParent2 = new DataIntegrationFields.ResponseParent();
    resParent2.externalId = 'DOES-NOT-EXIST-IN-MAP';
    resParent2.salesforceId = '001xx00000xxxx2BBB';
    resParent2.hasError = false;
    orderResponseList.add(resParent2);

    DataIntegrationFields.Response resChild = new DataIntegrationFields.Response();
    resChild.externalId = 'EXT-CHILD-001';
    resChild.hasError = true;

    orderItemResponseList.put(
      'EXT-001',
      new List<DataIntegrationFields.Response>{ resChild }
    );
    orderItemResponseList.put(
      '001xx00000xxxx2BBB',
      new List<DataIntegrationFields.Response>{ resChild }
    );

    Test.startTest();
    Boolean hasErrorResult = IntegrationInboundOneOrder.fillResponseList(
      orderResponseList,
      orderItemResponseList
    );
    Test.stopTest();

    System.assertEquals(
      true,
      hasErrorResult,
      'The method should detect that an internal error occurred'
    );
  }

  @IsTest
  public static void testUpdateOrderWithIntegrationLogIdOutbound() {
    List<Order> orders = [
      SELECT Id
      FROM Order
      WHERE ExternalId__c = 'TEST-ORDER-001'
      LIMIT 1
    ];
    System.assertEquals(
      1,
      orders.size(),
      'The setup order must exist in the database'
    );

    IntegrationLog__c fakeLog = (IntegrationLog__c) TestFactorySObject.getInstance()
      .createSObject(new IntegrationLog__c());
    insert fakeLog;

    Test.startTest();
    IntegrationInboundOneOrder.updateOrderWithIntegrationLogId(
      orders,
      fakeLog.Id,
      'OUT'
    );
    Test.stopTest();

    Order updatedOrder = [
      SELECT IntegrationLogOutbound__c
      FROM Order
      WHERE Id = :orders[0].Id
      LIMIT 1
    ];
    System.assertEquals(
      fakeLog.Id,
      updatedOrder.IntegrationLogOutbound__c,
      'The Outbound integration log field must be populated with the correct ID'
    );
  }
}
