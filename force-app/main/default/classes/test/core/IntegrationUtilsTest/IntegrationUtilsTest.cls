@IsTest
public with sharing class IntegrationUtilsTest {
  @TestSetup
  public static void makeData() {
    Group_Account__c groupAcc = new Group_Account__c();
    insert groupAcc;

    Account newAccount = new Account(
      Name = 'Name Test',
      CNPJ__c = '12345678901234',
      Group_Account__c = groupAcc.Id
    );
    insert newAccount;
  }

  @IsTest
  public static void upsertRecordsTest() {
    List<DataIntegrationFields.ResponseParent> responseList = new List<DataIntegrationFields.ResponseParent>();
    List<Account> accountList = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Name Test'
    ];
    Account newAccountError = new Account(Name = '');

    Test.startTest();
    IntegrationUtils.checkEmptyString('');
    IntegrationUtils.upsertRecords(
      Database.upsert(accountList, Account.Id, false),
      responseList,
      accountList,
      Account.Name
    );
    IntegrationUtils.upsertRecords(
      Database.upsert(new List<Account>{ newAccountError }, Account.Id, false),
      responseList,
      accountList,
      Account.Name
    );
    Test.stopTest();
  }

  @IsTest
  public static void upsertChildRecordsTest() {
    Map<String, List<DataIntegrationFields.Response>> responseMap = new Map<String, List<DataIntegrationFields.Response>>();
    List<Account> accountList = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Name Test'
    ];
    Map<String, String> accountMap = new Map<String, String>{
      accountList[0].Name => accountList[0].Name
    };
    List<Account> accountErrorList = new List<Account>{
      new Account(Name = '')
    };

    Test.startTest();
    IntegrationUtils.upsertChildRecords(
      Database.upsert(accountList, Account.Id, false),
      responseMap,
      accountList,
      accountMap,
      Account.Name
    );
    IntegrationUtils.upsertChildRecords(
      Database.upsert(accountErrorList, Account.Id, false),
      responseMap,
      accountList,
      accountMap,
      Account.Name
    );
    Test.stopTest();
  }

  @IsTest
  public static void executeCalloutTest() {
    String endpoint = 'https://example.com/services/apexrest/upsertOneOrder/';
    String payload = 'Class Test';
    Map<String, String> requestHeaders = new Map<String, String>{
      'Content-Type' => 'application/json',
      'Authorization' => 'Bearer ' + 'Test'
    };
    String method = 'POST';
    Integer timeout = 110000;

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(true, TestUtility.getBody(), TestUtility.getBody())
    );
    IntegrationUtils.executeCallout(
      endpoint,
      payload,
      requestHeaders,
      method,
      timeout
    );
    Test.stopTest();
  }

  @IsTest
  public static void checkEmptyStringVariationsTest() {
    Test.startTest();
    Boolean resultNull = IntegrationUtils.checkEmptyString(null);
    System.assertEquals(true, resultNull, 'null should be empty');

    Boolean resultEmpty = IntegrationUtils.checkEmptyString('');
    System.assertEquals(true, resultEmpty, 'empty string should be empty');

    Boolean resultNullString = IntegrationUtils.checkEmptyString('null');
    System.assertEquals(
      true,
      resultNullString,
      '"null" string should be empty'
    );

    Boolean resultValid = IntegrationUtils.checkEmptyString('test');
    System.assertEquals(false, resultValid, 'valid value should not be empty');

    Boolean resultZero = IntegrationUtils.checkEmptyString(0);
    System.assertEquals(false, resultZero, 'zero should not be empty');
    Test.stopTest();
  }

  @IsTest
  public static void executeCalloutWithoutHeadersTest() {
    String endpoint = 'https://example.com/services/apexrest/test/';
    String payload = 'Test';
    String method = 'GET';
    Integer timeout = 5000;

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(true, TestUtility.getBody(), TestUtility.getBody())
    );
    IntegrationUtils.executeCallout(endpoint, payload, null, method, timeout);
    Test.stopTest();
  }
}
