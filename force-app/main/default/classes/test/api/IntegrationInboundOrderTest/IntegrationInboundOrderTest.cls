@IsTest
public with sharing class IntegrationInboundOrderTest {
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
    acc.Name = 'Test Customer ' + timestamp;
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

    Margin__c margin = (Margin__c) TestFactorySObject.getInstance()
      .createSObject(new Margin__c());
    margin.Account__c = acc.Id;
    margin.Distribution_Center__c = dc.Id;
    margin.Value__c = 20;
    insert margin;

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
    List<DataIntegrationFields.OrderINData> orderRequestList = new List<DataIntegrationFields.OrderINData>();

    DataIntegrationFields.OrderINData orderData = new DataIntegrationFields.OrderINData();
    orderData.externalId = 'TEST-ORDER-NEW';
    orderData.status = 'Draft';
    orderData.effectiveDate = '2026-05-13';
    orderData.deliveryDate = '2026-05-20';

    orderData.orderItemList = new List<DataIntegrationFields.OrderItemINData>();
    DataIntegrationFields.OrderItemINData itemData = new DataIntegrationFields.OrderItemINData();
    itemData.externalId = 'ITEM-NEW-001';
    itemData.quantity = 5;
    itemData.unitPrice = 100;
    orderData.orderItemList.add(itemData);

    orderRequestList.add(orderData);

    Test.startTest();
    List<DataIntegrationFields.Response> responses = IntegrationInboundOrder.upsertOrder(
      orderRequestList
    );
    Test.stopTest();

    System.assertNotEquals(null, responses);
  }

  @IsTest
  public static void testUpsertOrderEmptyListForLogCoverage() {
    List<DataIntegrationFields.OrderINData> emptyList = new List<DataIntegrationFields.OrderINData>();

    Test.startTest();
    List<DataIntegrationFields.Response> responses = IntegrationInboundOrder.upsertOrder(
      emptyList
    );
    Test.stopTest();

    System.assertEquals(0, responses.size());
  }

  @IsTest
  public static void testDeletedOrderItemLogical() {
    List<DataIntegrationFields.OrderItemINData> orderItemRequestList = new List<DataIntegrationFields.OrderItemINData>();

    DataIntegrationFields.OrderItemINData itemData = new DataIntegrationFields.OrderItemINData();
    itemData.externalId = 'OUTRO-ITEM';
    itemData.orderExternalId = 'TEST-ORDER-001';
    orderItemRequestList.add(itemData);

    Test.startTest();
    Boolean hasDeletedLogical = IntegrationInboundOrder.deletedOrderItem(
      orderItemRequestList,
      false
    );
    Test.stopTest();

    System.assertEquals(true, hasDeletedLogical);
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
    itemData.externalId = 'OUTRO-ITEM';
    itemData.orderExternalId = 'TEST-ORDER-001';
    orderItemRequestList.add(itemData);

    Test.startTest();
    Boolean hasDeletedPhysical = IntegrationInboundOrder.deletedOrderItem(
      orderItemRequestList,
      true
    );
    Test.stopTest();

    System.assertEquals(true, hasDeletedPhysical);
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
    resParent2.externalId = 'DOES-NOT-EXIST-ON-THE-MAP';
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
    Boolean hasErrorResult = IntegrationInboundOrder.fillResponseList(
      orderResponseList,
      orderItemResponseList
    );
    Test.stopTest();

    System.assertEquals(true, hasErrorResult);
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
    IntegrationInboundOrder.updateOrderWithIntegrationLogId(
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
      'O campo de log Outbound deve ter sido preenchido com o ID correto'
    );
  }
}
