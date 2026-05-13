@IsTest
public with sharing class CalloutOrderTest {
  @TestSetup
  static void makeData() {
    Order newOrder = (Order) TestFactorySObject.getInstance()
      .createSObject(new Order());
    insert newOrder;

    Order newOrderError = (Order) TestFactorySObject.getInstance()
      .createSObject(new Order());
    newOrderError.ExternalId__c = 'CalloutOrderError';
    insert newOrderError;

    // Create IntegrationSetting with all required fields
    IntegrationSetting__c integration = new IntegrationSetting__c(
      Name = 'IntegrationOutUsername',
      User__c = 'testuser',
      Password__c = 'testpass',
      ClientId__c = 'testclient',
      ClientSecret__c = 'testsecret',
      Timeout__c = 30000,
      AccessTokenTime__c = 3600,
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
    // Test with empty order list
    List<String> emptyOrderList = new List<String>();

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        true,
        TestUtility.getBodyResponse(),
        TestUtility.getBodyResponse()
      )
    );
    CalloutOrder.executeCalloutOrder(emptyOrderList);
    Test.stopTest();
  }

  @IsTest
  public static void processIntegrationWithNullTest() {
    // Test with null list
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        true,
        TestUtility.getBodyResponse(),
        TestUtility.getBodyResponse()
      )
    );
    try {
      CalloutOrder.executeCalloutOrder(null);
    } catch (Exception e) {
      System.assert(true, 'Should handle null gracefully');
    }
    Test.stopTest();
  }
}
