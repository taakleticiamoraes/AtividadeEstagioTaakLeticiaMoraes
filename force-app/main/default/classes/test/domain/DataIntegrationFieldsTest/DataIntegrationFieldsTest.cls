@IsTest
public class DataIntegrationFieldsTest {
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

    contract.Status = 'Integrated';
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

    /*PricebookEntry standardPBE = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(),
        Product2Id = product.Id,
        UnitPrice = 100,
        IsActive = true
            );
        insert standardPBE;*/

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
    order.ExternalId__c = 'ORD-' + timestamp;
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
      ExternalId__c = 'OI-' + timestamp,
      OrderId = order.Id,
      PricebookEntryId = customPBE.Id,
      Quantity = 5,
      UnitPrice = 100,
      Selling_Price__c = 120,
      Production_Cost__c = 80
    );
    insert orderItem;
  }

  @IsTest
  public static void testOrderINDataDeserialize() {
    DataIntegrationFields.OrderINData orderINData = new DataIntegrationFields.OrderINData();
    orderINData.externalId = 'TEST-ORD-001';
    orderINData.status = 'Draft';
    orderINData.effectiveDate = '2026-05-13';
    orderINData.accountExternalId = 'ACC-TEST-001';
    orderINData.pricebook2ExternalId = 'PB-001';
    orderINData.shippingType = 'Ground';
    orderINData.addressName = '01234-567';
    orderINData.distributionCenterName = 'DC-TEST';
    orderINData.deliveryDate = '2026-05-20';
    orderINData.paymentTermsName = 'NET30';
    orderINData.contractExternalId = 'CONT-001';

    Test.startTest();
    Order deserializedOrder = orderINData.deserialize();
    Test.stopTest();

    System.assertEquals('TEST-ORD-001', deserializedOrder.ExternalId__c);
    System.assertEquals('Draft', deserializedOrder.Status);
    System.assertEquals(
      Date.valueOf('2026-05-13'),
      deserializedOrder.EffectiveDate
    );
  }

  @IsTest
  public static void testOrderINDataDeserializeWithNullDates() {
    DataIntegrationFields.OrderINData orderINData = new DataIntegrationFields.OrderINData();
    orderINData.externalId = 'TEST-ORD-NULL';
    orderINData.status = 'draft';
    orderINData.effectiveDate = null;
    orderINData.deliveryDate = null;
    orderINData.accountExternalId = 'ACC-TEST';
    orderINData.pricebook2ExternalId = 'PB-001';

    Test.startTest();
    Order deserializedOrder = orderINData.deserialize();
    Test.stopTest();
  }

  @IsTest
  public static void testOrderINDataGetRequiredFields() {
    DataIntegrationFields.OrderINData orderINData = new DataIntegrationFields.OrderINData();

    Test.startTest();
    List<String> requiredFields = orderINData.getRequiredFields();
    List<String> requiredLookups = orderINData.getRequiredLookups();
    Test.stopTest();

    System.assert(requiredFields.contains('ExternalId__c'));
    System.assert(requiredFields.contains('EffectiveDate'));
    System.assert(requiredFields.contains('Status'));
    System.assert(requiredLookups.contains('AccountId'));
  }

  @IsTest
  public static void testOrderINDataGetFieldKey() {
    DataIntegrationFields.OrderINData orderINData = new DataIntegrationFields.OrderINData();

    Test.startTest();
    String fieldKey = orderINData.getFieldKey();
    Test.stopTest();

    System.assertEquals('ExternalId__c', fieldKey);
  }

  @IsTest
  public static void testOrderINDataGetFieldId() {
    DataIntegrationFields.OrderINData orderINData = new DataIntegrationFields.OrderINData();

    Test.startTest();
    String fieldId = orderINData.getFieldId();
    Test.stopTest();

    System.assertEquals('Id', fieldId);
  }

  @IsTest
  public static void testOrderINDataGetExternalId() {
    DataIntegrationFields.OrderINData orderINData = new DataIntegrationFields.OrderINData();
    orderINData.externalId = 'EXT-ID-123';

    Test.startTest();
    String extId = orderINData.getExternalId();
    Test.stopTest();

    System.assertEquals('EXT-ID-123', extId);
  }

  @IsTest
  public static void testOrderItemINDataDeserialize() {
    DataIntegrationFields.OrderItemINData orderItemINData = new DataIntegrationFields.OrderItemINData();
    orderItemINData.externalId = 'OI-TEST-001';
    orderItemINData.quantity = 10;
    orderItemINData.orderExternalId = 'ORD-001';
    orderItemINData.unitPrice = 100;
    orderItemINData.sellingPrice = 120;
    orderItemINData.productionCost = 80;
    orderItemINData.pricebookEntryExternalId = 'PBE-001';

    Test.startTest();
    OrderItem deserializedOrderItem = orderItemINData.deserialize();
    Test.stopTest();

    System.assertEquals('OI-TEST-001', deserializedOrderItem.ExternalId__c);
    System.assertEquals(10, deserializedOrderItem.Quantity);
    System.assertEquals(120, deserializedOrderItem.Selling_Price__c);
  }

  @IsTest
  public static void testOrderItemINDataDeserializeWithId() {
    OrderItem existingOrderItem = [SELECT Id FROM OrderItem LIMIT 1];

    DataIntegrationFields.OrderItemINData orderItemINData = new DataIntegrationFields.OrderItemINData();
    orderItemINData.id = existingOrderItem.Id;
    orderItemINData.externalId = 'OI-UPDATE';
    orderItemINData.quantity = 15;
    orderItemINData.unitPrice = 110;
    orderItemINData.sellingPrice = 130;
    orderItemINData.productionCost = 85;
    orderItemINData.pricebookEntryExternalId = 'PBE-001';

    Test.startTest();
    OrderItem deserializedOrderItem = orderItemINData.deserialize();
    Test.stopTest();

    System.assertEquals(existingOrderItem.Id, deserializedOrderItem.Id);
  }

  @IsTest
  public static void testOrderItemINDataGetRequiredFields() {
    DataIntegrationFields.OrderItemINData orderItemINData = new DataIntegrationFields.OrderItemINData();

    Test.startTest();
    List<String> requiredFields = orderItemINData.getRequiredFields();
    List<String> requiredLookups = orderItemINData.getRequiredLookups();
    Test.stopTest();

    System.assert(requiredFields.contains('UnitPrice'));
    System.assert(requiredFields.contains('Quantity'));
    System.assert(requiredFields.contains('ExternalId__c'));
    System.assert(requiredLookups.contains('OrderId'));
  }

  @IsTest
  public static void testOrderItemINDataGetFieldId() {
    DataIntegrationFields.OrderItemINData orderItemINData = new DataIntegrationFields.OrderItemINData();

    Test.startTest();
    String fieldId = orderItemINData.getFieldId();
    Test.stopTest();

    System.assertEquals('Id', fieldId);
  }

  @IsTest
  public static void testOrderItemINDataGetFieldExternal() {
    DataIntegrationFields.OrderItemINData orderItemINData = new DataIntegrationFields.OrderItemINData();

    Test.startTest();
    String fieldExternal = orderItemINData.getFieldExternal();
    Test.stopTest();

    System.assertEquals('ExternalId__c', fieldExternal);
  }

  @IsTest
  public static void testOrderItemINDataGetParentId() {
    DataIntegrationFields.OrderItemINData orderItemINData = new DataIntegrationFields.OrderItemINData();

    Test.startTest();
    String parentId = orderItemINData.getParentId();
    Test.stopTest();

    System.assertEquals('OrderId', parentId);
  }

  @IsTest
  public static void testOrderItemINDataGetParentKey() {
    DataIntegrationFields.OrderItemINData orderItemINData = new DataIntegrationFields.OrderItemINData();
    orderItemINData.orderExternalId = 'PARENT-ORD-123';

    Test.startTest();
    String parentKey = orderItemINData.getParentKey();
    Test.stopTest();

    System.assertEquals('PARENT-ORD-123', parentKey);
  }

  @IsTest
  public static void testResponseSuccess() {
    DataIntegrationFields.Response response = new DataIntegrationFields.Response();

    Test.startTest();
    response.success('SF-ID-001', 'EXT-ID-001', 'Order');
    Test.stopTest();

    System.assertEquals('SF-ID-001', response.salesforceId);
    System.assertEquals('EXT-ID-001', response.externalId);
    System.assertEquals('Order', response.sobjectType);
    System.assertEquals(false, response.hasError);
  }

  @IsTest
  public static void testResponseErrorTwoParam() {
    DataIntegrationFields.Response response = new DataIntegrationFields.Response();

    Test.startTest();
    response.error('EXT-ID-001', 'Invalid record', 'Order');
    Test.stopTest();

    System.assertEquals('EXT-ID-001', response.externalId);
    System.assertEquals('Invalid record', response.errorMessage);
    System.assertEquals('Order', response.sobjectType);
    System.assertEquals(true, response.hasError);
  }

  @IsTest
  public static void testResponseErrorThreeParam() {
    DataIntegrationFields.Response response = new DataIntegrationFields.Response();

    Test.startTest();
    response.error('SF-ID-001', 'EXT-ID-001', 'Invalid record', 'OrderItem');
    Test.stopTest();

    System.assertEquals('SF-ID-001', response.salesforceId);
    System.assertEquals('EXT-ID-001', response.externalId);
    System.assertEquals('Invalid record', response.errorMessage);
    System.assertEquals('OrderItem', response.sobjectType);
    System.assertEquals(true, response.hasError);
  }

  @IsTest
  public static void testResponseParent() {
    DataIntegrationFields.ResponseParent responseParent = new DataIntegrationFields.ResponseParent();

    Test.startTest();
    responseParent.success('SF-ID-001', 'EXT-ID-001', 'Order');
    responseParent.items = new List<DataIntegrationFields.Response>();
    DataIntegrationFields.Response childResponse = new DataIntegrationFields.Response();
    childResponse.success('SF-ITEM-001', 'EXT-ITEM-001', 'OrderItem');
    responseParent.items.add(childResponse);
    Test.stopTest();

    System.assertEquals('SF-ID-001', responseParent.salesforceId);
    System.assertEquals(1, responseParent.items.size());
  }

  @IsTest
  public static void testRequestResponseObjectSuccess() {
    HttpResponse httpResponse = new HttpResponse();
    httpResponse.setStatusCode(200);

    Test.startTest();
    DataIntegrationFields.RequestResponseObject reqResObj = new DataIntegrationFields.RequestResponseObject(
      httpResponse
    );
    Test.stopTest();

    System.assertEquals(true, reqResObj.success);
    System.assertEquals(200, reqResObj.response.getStatusCode());
    System.assertEquals(null, reqResObj.exceptionObject);
  }

  @IsTest
  public static void testRequestResponseObjectException() {
    Exception testException = new DmlException();

    Test.startTest();
    DataIntegrationFields.RequestResponseObject reqResObj = new DataIntegrationFields.RequestResponseObject(
      testException
    );
    Test.stopTest();

    System.assertEquals(false, reqResObj.success);
    System.assertEquals(null, reqResObj.response);
    System.assertNotEquals(null, reqResObj.exceptionObject);
  }

  @IsTest
  public static void testCalloutResponseWithError() {
    Test.startTest();
    DataIntegrationFields.CalloutResponse calloutRes = new DataIntegrationFields.CalloutResponse(
      'Test error message'
    );
    Test.stopTest();

    System.assertEquals(true, calloutRes.hasError);
    System.assertEquals('Test error message', calloutRes.errorMessage);
  }

  @IsTest
  public static void testCalloutResponseWithSingleResponse() {
    DataIntegrationFields.ResponseParametersWrapper responseWrapper = new DataIntegrationFields.ResponseParametersWrapper();
    responseWrapper.hasError = false;
    responseWrapper.salesforceId = 'SF-001';
    responseWrapper.externalId = 'EXT-001';

    Test.startTest();
    DataIntegrationFields.CalloutResponse calloutRes = new DataIntegrationFields.CalloutResponse(
      responseWrapper,
      false
    );
    Test.stopTest();

    System.assertEquals(false, calloutRes.hasError);
    System.assertEquals('SF-001', calloutRes.parsedResponse.salesforceId);
  }

  @IsTest
  public static void testCalloutResponseWithMultipleResponses() {
    List<DataIntegrationFields.ResponseParametersWrapper> responseList = new List<DataIntegrationFields.ResponseParametersWrapper>();

    DataIntegrationFields.ResponseParametersWrapper response1 = new DataIntegrationFields.ResponseParametersWrapper();
    response1.hasError = false;
    response1.externalId = 'EXT-001';
    responseList.add(response1);

    Test.startTest();
    DataIntegrationFields.CalloutResponse calloutRes = new DataIntegrationFields.CalloutResponse(
      responseList,
      false
    );
    Test.stopTest();

    System.assertEquals(false, calloutRes.hasError);
    System.assertEquals(1, calloutRes.parsedResponses.size());
  }

  @IsTest
  public static void testResponseAccessToken() {
    Test.startTest();
    DataIntegrationFields.ResponseAccessToken accessToken = new DataIntegrationFields.ResponseAccessToken();
    accessToken.access_token = 'token123';
    accessToken.error = null;
    accessToken.error_description = null;
    Test.stopTest();

    System.assertEquals('token123', accessToken.access_token);
    System.assertEquals(null, accessToken.error);
  }

  @IsTest
  public static void testResponseParametersWrapper() {
    Test.startTest();
    DataIntegrationFields.ResponseParametersWrapper wrapper = new DataIntegrationFields.ResponseParametersWrapper();
    wrapper.hasError = true;
    wrapper.errorMessage = 'Field validation error';
    wrapper.salesforceId = 'SF-001';
    wrapper.externalId = 'EXT-001';
    wrapper.sobjectType = 'Order';
    wrapper.items = new List<DataIntegrationFields.ResponseParametersWrapper>();
    Test.stopTest();

    System.assertEquals(true, wrapper.hasError);
    System.assertEquals('Field validation error', wrapper.errorMessage);
    System.assertEquals(0, wrapper.items.size());
  }

  @IsTest
  public static void testRequestAndOrderParameters() {
    Order testOrder = [
      SELECT
        EffectiveDate,
        Type_of_shipping__c,
        Delivery_Date__c,
        Account.ExternalId__c,
        Pricebook2.ExternalId__c,
        Address__r.CEP__c,
        Distribution_Center__r.Name,
        Payment_Terms__r.Name,
        Contract.ExternalId__c,
        ExternalId__c,
        (
          SELECT
            ExternalId__c,
            Quantity,
            UnitPrice,
            PricebookEntry.ExternalId__c,
            Selling_Price__c,
            Production_Cost__c,
            Order.ExternalId__c
          FROM OrderItems
        )
      FROM Order
      LIMIT 1
    ];

    Test.startTest();
    DataIntegrationFields.OrderParameters orderParam = new DataIntegrationFields.OrderParameters(
      testOrder
    );

    DataIntegrationFields.Request singleRequest = new DataIntegrationFields.Request(
      orderParam
    );

    List<DataIntegrationFields.OrderParameters> paramList = new List<DataIntegrationFields.OrderParameters>{
      orderParam
    };
    DataIntegrationFields.RequestList requestList = new DataIntegrationFields.RequestList(
      paramList
    );
    Test.stopTest();

    System.assertNotEquals(null, orderParam.orderItemList);
    System.assertEquals(1, orderParam.orderItemList.size());
  }
}
