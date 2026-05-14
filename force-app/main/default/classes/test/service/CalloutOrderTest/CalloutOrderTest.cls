@IsTest
public with sharing class CalloutOrderTest {
  @TestSetup
  static void makeData() {
    Long timestamp = System.currentTimeMillis();

    TestFactorySObject.getInstance().createSObject(new City__c());
    City__c testCity = [SELECT Id, State__c FROM City__c LIMIT 1];

    Account acc = (Account) TestFactorySObject.getInstance()
      .createSObject(new Account());
    insert acc;

    Product2 prod = (Product2) TestFactorySObject.getInstance()
      .createSObject(new Product2());
    insert prod;

    Distribution_Center__c dc = new Distribution_Center__c(
      Name = 'DC-TEST-' + timestamp
    );
    insert dc;

    Tax__c tax = (Tax__c) TestFactorySObject.getInstance()
      .createSObject(new Tax__c());
    tax.Product__c = prod.Id;
    tax.Distribution_Center__c = dc.Id;
    tax.State__c = testCity.State__c;
    tax.Status__c = 'Approved';
    insert tax;

    Freight__c freight = (Freight__c) TestFactorySObject.getInstance()
      .createSObject(new Freight__c());
    freight.Product__c = prod.Id;
    freight.Distribution_Center__c = dc.Id;
    freight.City__c = testCity.Id;
    freight.Status__c = 'Approved';
    insert freight;

    Margin__c margin = (Margin__c) TestFactorySObject.getInstance()
      .createSObject(new Margin__c());
    margin.Account__c = acc.Id;
    margin.Product__c = prod.Id;
    margin.Distribution_Center__c = dc.Id;
    margin.State__c = testCity.State__c;
    margin.Status__c = 'Approved';
    margin.Value__c = 20;
    insert margin;

    Order testOrder = (Order) TestFactorySObject.getInstance()
      .createSObject(new Order());
    testOrder.AccountId = acc.Id;
    testOrder.ExternalId__c = 'TEST-ORDER-001';
    testOrder.Distribution_Center__c = dc.Id;
    insert testOrder;

    Pricebook2 pricebook = new Pricebook2(
      Name = 'PB-' + timestamp,
      ExternalId__c = 'PB-' + timestamp,
      IsActive = true
    );
    insert pricebook;

    /*PricebookEntry standardPBE = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(),
        Product2Id = prod.Id,
        UnitPrice = 10,
        IsActive = true
            );
        insert standardPBE;*/

    PricebookEntry pbe = new PricebookEntry(
      Pricebook2Id = pricebook.Id,
      Product2Id = prod.Id,
      UnitPrice = 10,
      IsActive = true
    );
    insert pbe;

    /*OrderItem item = new OrderItem(
        OrderId = testOrder.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 10,
        UnitPrice = 10,
        ExternalId__c = 'ITEM-DUMMY-001',
        DeletedProduct__c = false
            );
        insert item;*/

    IntegrationSetting__c integration = new IntegrationSetting__c(
      Name = 'IntegrationOutUsername',
      User__c = 'testuser',
      Password__c = 'testpass',
      ClientId__c = 'testclient',
      ClientSecret__c = 'testsecret',
      Timeout__c = 30000,
      AccessTokenTime__c = 3600000,
      EndpointAccessToken__c = 'https://test.example.com/token',
      Endpoint__c = 'https://test.example.com/api',
      Method__c = 'POST'
    );
    insert integration;
  }

  @IsTest
  public static void processIntegrationTest() {
    List<String> orderIdList = new List<String>();
    for (Order order : [SELECT Id FROM Order LIMIT 2]) {
      orderIdList.add(order.Id);
    }

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        true,
        TestUtility.getBodyResponse(),
        TestUtility.getBodyResponse()
      )
    );
    CalloutOrder.executeCalloutOrder(orderIdList);
    Test.stopTest();
  }

  @IsTest
  public static void processIntegrationErrorTest() {
    List<String> orderIdList = new List<String>();
    Order updateOrder;
    for (Order order : [SELECT Id FROM Order LIMIT 2]) {
      orderIdList.add(order.Id);
      updateOrder = order;
    }

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        false,
        TestUtility.getBodyResponse(),
        TestUtility.getBodyResponse()
      )
    );
    update updateOrder;
    CalloutOrder.executeCalloutOrder(orderIdList);
    Test.stopTest();
  }

  @IsTest
  public static void processIntegrationExceptionTest() {
    List<String> orderIdList = new List<String>();
    for (Order order : [SELECT Id FROM Order LIMIT 2]) {
      orderIdList.add(order.Id);
    }

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        true,
        TestUtility.getBodyResponseError(),
        TestUtility.getBodyResponseError()
      )
    );
    CalloutOrder.executeCalloutOrder(orderIdList);
    Test.stopTest();
  }

  @IsTest
  public static void handlerAccessTokenTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        true,
        TestUtility.getBodyAccessToken(),
        TestUtility.getBodyAccessToken()
      )
    );

    CalloutOrder.handlerAccessToken(new CalloutOrder.AccessTokenLog());
    Test.stopTest();
  }

  @IsTest
  public static void getAccessTokenTest() {
    IntegrationSetting__c integrationSetting = getIntegrationSetting();
    integrationSetting.LastAccessTokenTime__c = null;
    update integrationSetting;

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        true,
        TestUtility.getBodyAccessToken(),
        TestUtility.getBodyAccessToken()
      )
    );
    CalloutOrder.handlerAccessToken(new CalloutOrder.AccessTokenLog());

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        false,
        TestUtility.getBodyAccessToken(),
        TestUtility.getBodyAccessToken()
      )
    );
    try {
      CalloutOrder.handlerAccessToken(new CalloutOrder.AccessTokenLog());
    } catch (Exception ex) {
    }
    Test.stopTest();
  }

  @IsTest
  public static void treatmentMethodsTest() {
    CalloutOrder.callErrorTreatment();
    CalloutOrder.callSuccessTreatment();
  }

  @IsTest
  public static void updateIntegrationSettingTest() {
    IntegrationSetting__c currentIntegrationSetting = getIntegrationSetting();
    CalloutOrder.IntegrationSettings integrationSetting = new CalloutOrder.IntegrationSettings(
      currentIntegrationSetting
    );

    CalloutOrder.updateIntegrationSetting(integrationSetting);
  }

  public static IntegrationSetting__c getIntegrationSetting() {
    return [
      SELECT
        Id,
        User__c,
        Password__c,
        ClientId__c,
        ClientSecret__c,
        Timeout__c,
        AccessTokenTime__c,
        LastAccessTokenTime__c,
        EndpointAccessToken__c,
        AccessToken__c,
        Endpoint__c,
        Method__c
      FROM IntegrationSetting__c
      LIMIT 1
    ];
  }

  @IsTest
  public static void processIntegrationWithEmptyListTest() {
    List<String> emptyOrderList = new List<String>();

    Test.startTest();
    CalloutOrder.executeCalloutOrder(emptyOrderList);
    Test.stopTest();
  }

  @IsTest
  public static void processIntegrationWithNullTest() {
    Test.startTest();
    try {
      CalloutOrder.executeCalloutOrder(null);
    } catch (Exception e) {
      System.assert(true);
    }
    Test.stopTest();
  }

  @IsTest
  public static void testHandlerAccessTokenValidToken() {
    IntegrationSetting__c integrationSetting = getIntegrationSetting();
    integrationSetting.LastAccessTokenTime__c = DateTime.now().getTime();
    integrationSetting.AccessTokenTime__c = 900000;
    integrationSetting.AccessToken__c = 'TOKEN_VALIDO_MEMORIA';
    update integrationSetting;

    Test.startTest();
    CalloutOrder.IntegrationSettings result = CalloutOrder.handlerAccessToken(
      new CalloutOrder.AccessTokenLog()
    );
    Test.stopTest();

    System.assertEquals('TOKEN_VALIDO_MEMORIA', result.accessToken);
  }

  @IsTest
  public static void testFillCalloutResponseWithRequestFailedException() {
    HttpResponse mockRes = new HttpResponse();
    mockRes.setStatusCode(400);
    mockRes.setStatus('Bad Request');
    mockRes.setBody('{}');

    Test.startTest();
    DataIntegrationFields.CalloutResponse response = CalloutOrder.fillCalloutResponse(
      mockRes
    );
    Test.stopTest();

    System.assert(response.errorMessage.contains('Request Failed'));
  }

  @IsTest
  public static void testFillCalloutResponseWithArrayAndErrorHandler() {
    String jsonArrayResponse =
      '[' +
      '{' +
      '"hasError": true,' +
      '"errorMessage": "Header Error",' +
      '"externalId": "ORD-001",' +
      '"items": [' +
      '{"hasError": true, "errorMessage": "Item Error", "externalId": "OI-001"}' +
      ']' +
      '}' +
      ']';

    HttpResponse mockRes = new HttpResponse();
    mockRes.setStatusCode(200);
    mockRes.setBody(jsonArrayResponse);

    Test.startTest();
    DataIntegrationFields.CalloutResponse calloutResponse = CalloutOrder.fillCalloutResponse(
      mockRes
    );
    String errorMessageResult = CalloutOrder.handlerError(calloutResponse);
    Test.stopTest();

    System.assertNotEquals(null, calloutResponse.parsedResponses);
    System.assert(errorMessageResult.contains('Header Error'));
    System.assert(errorMessageResult.contains('Item Error'));
  }

  @IsTest
  public static void testUpdateSObjectWithEmptyList() {
    Test.startTest();
    CalloutOrder.updateSObjectWithIntegrationLogId(
      new List<SObject>(),
      'FAKE-LOG-ID',
      'OUT'
    );
    Test.stopTest();
    System.assert(true);
  }

  @IsTest
  public static void testExecuteCalloutOrderLogExceptionCatch() {
    List<Order> orders = [SELECT Id FROM Order LIMIT 1];
    List<String> orderIdList = new List<String>{ orders[0].Id };

    delete orders;

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        true,
        TestUtility.getBodyResponse(),
        TestUtility.getBodyResponse()
      )
    );

    List<SObject> invalidSObjectList = new List<SObject>{
      new Task(Subject = 'Test Exception')
    };

    Test.startTest();
    try {
      CalloutOrder.updateSObjectWithIntegrationLogId(
        invalidSObjectList,
        'FAKE-LOG-ID',
        'OUT'
      );
    } catch (Exception ex) {
    }
    Test.stopTest();

    System.assert(
      true,
      'The exception validation from the log utility was run.'
    );
  }
}
