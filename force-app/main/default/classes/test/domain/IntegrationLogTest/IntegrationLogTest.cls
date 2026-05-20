@IsTest
public with sharing class IntegrationLogTest {
  @IsTest
  public static void createLogTest() {
    TestFactorySObject sobjectFactory = TestFactorySObject.getInstance();
    Order testOrder = (Order) sobjectFactory.createSObject(new Order());
    insert testOrder;

    Datetime datetimeNow = System.now();
    String integrationName = 'Order';
    List<String> externalIdList = new List<String>{ '1000', '1001' };
    String recordTypeName = 'Inbound';
    String payloadIN = 'Class Test';
    String payloadOUT = '';
    String endpoint = '';
    Boolean hasAnyErrors = false;
    Boolean hasDeleted = false;

    Test.startTest();
    IntegrationLog.createLog(
      integrationName,
      externalIdList,
      recordTypeName,
      payloadIN,
      payloadOUT,
      '',
      endpoint,
      200,
      hasAnyErrors,
      hasDeleted,
      testOrder
    );

    String logId = IntegrationLog.createLog(
      integrationName,
      externalIdList,
      recordTypeName,
      payloadIN,
      payloadOUT,
      '',
      endpoint,
      200,
      hasAnyErrors,
      hasDeleted,
      testOrder
    );

    IntegrationLog.createAttachment(
      logId,
      integrationName,
      recordTypeName,
      integrationName,
      String.valueOf(datetimeNow),
      payloadIN
    );
    Test.stopTest();
  }

  @IsTest
  public static void createLogWithLargePayloadTest() {
    TestFactorySObject sobjectFactory = TestFactorySObject.getInstance();
    Order testOrder = (Order) sobjectFactory.createSObject(new Order());
    insert testOrder;

    String integrationName = 'Order';
    List<String> externalIdList = new List<String>{ '1000', '1001' };
    String recordTypeName = 'Inbound';
    String largePayload = 'x'.repeat(140000);
    String payloadOUT = 'y'.repeat(140000);
    String endpoint = '';
    Boolean hasAnyErrors = true;
    Boolean hasDeleted = true;

    Test.startTest();
    String logId = IntegrationLog.createLog(
      integrationName,
      externalIdList,
      recordTypeName,
      largePayload,
      payloadOUT,
      'Test Error Message',
      endpoint,
      500,
      hasAnyErrors,
      hasDeleted,
      testOrder
    );
    System.assertNotEquals(null, logId, 'Log ID should not be null');
    Test.stopTest();
  }

  @IsTest
  public static void createLogWithNullOrderTest() {
    String integrationName = 'Order';
    List<String> externalIdList = new List<String>{ '1000' };
    String recordTypeName = 'Outbound';
    String payloadIN = 'Test';
    String payloadOUT = 'Test';
    String endpoint = '';

    Test.startTest();
    String logId = IntegrationLog.createLog(
      integrationName,
      externalIdList,
      recordTypeName,
      payloadIN,
      payloadOUT,
      '',
      endpoint,
      200,
      false,
      false,
      null
    );
    System.assertNotEquals(
      null,
      logId,
      'Log ID should not be null even with null Order'
    );
    Test.stopTest();
  }

  @IsTest
  public static void createLogWithEmptyExternalIdListTest() {
    TestFactorySObject sobjectFactory = TestFactorySObject.getInstance();
    Order testOrder = (Order) sobjectFactory.createSObject(new Order());
    insert testOrder;

    String integrationName = 'Order';
    List<String> emptyExternalIdList = new List<String>();
    String recordTypeName = 'Inbound';
    String payloadIN = 'Test Payload';
    String payloadOUT = 'Response';
    String endpoint = 'https://api.example.com/order';

    Test.startTest();
    String logId = IntegrationLog.createLog(
      integrationName,
      emptyExternalIdList,
      recordTypeName,
      payloadIN,
      payloadOUT,
      '',
      endpoint,
      200,
      false,
      false,
      testOrder
    );
    System.assertNotEquals(
      null,
      logId,
      'Log ID should not be null with empty external IDs'
    );
    Test.stopTest();
  }

  @IsTest
  public static void createLogWithErrorMessageTest() {
    TestFactorySObject sobjectFactory = TestFactorySObject.getInstance();
    Order testOrder = (Order) sobjectFactory.createSObject(new Order());
    insert testOrder;

    String integrationName = 'Order';
    List<String> externalIdList = new List<String>{ '2000', '2001', '2002' };
    String recordTypeName = 'Inbound';
    String payloadIN = 'Request Data';
    String payloadOUT = 'Response Data';
    String errorMessage = 'Detailed error message for integration failure';
    String endpoint = 'https://api.example.com/orders';

    Test.startTest();
    String logId = IntegrationLog.createLog(
      integrationName,
      externalIdList,
      recordTypeName,
      payloadIN,
      payloadOUT,
      errorMessage,
      endpoint,
      400,
      true,
      false,
      testOrder
    );
    System.assertNotEquals(
      null,
      logId,
      'Log ID should be created even with errors'
    );

    IntegrationLog__c createdLog = [
      SELECT ErrorMessage__c, Status__c
      FROM IntegrationLog__c
      WHERE Id = :logId
      LIMIT 1
    ];
    System.assertEquals('Error', createdLog.Status__c);
    System.assertEquals(errorMessage, createdLog.ErrorMessage__c);
    Test.stopTest();
  }

  @IsTest
  public static void createLogWithDifferentHttpStatusCodesTest() {
    TestFactorySObject sobjectFactory = TestFactorySObject.getInstance();
    Order testOrder = (Order) sobjectFactory.createSObject(new Order());
    insert testOrder;

    List<String> externalIdList = new List<String>{ '3000' };

    Test.startTest();
    String logId1 = IntegrationLog.createLog(
      'Order',
      externalIdList,
      'Outbound',
      'Data',
      'Response',
      '',
      '',
      201,
      false,
      false,
      testOrder
    );
    System.assertNotEquals(null, logId1);

    String logId2 = IntegrationLog.createLog(
      'Order',
      externalIdList,
      'Inbound',
      'Data',
      '',
      'Unauthorized',
      '',
      401,
      true,
      false,
      testOrder
    );
    System.assertNotEquals(null, logId2);

    String logId3 = IntegrationLog.createLog(
      'Order',
      externalIdList,
      'Inbound',
      'Data',
      '',
      'Server error',
      '',
      500,
      true,
      false,
      testOrder
    );
    System.assertNotEquals(null, logId3);
    Test.stopTest();
  }

  @IsTest
  public static void createAttachmentDirectlyTest() {
    TestFactorySObject sobjectFactory = TestFactorySObject.getInstance();
    Order testOrder = (Order) sobjectFactory.createSObject(new Order());
    insert testOrder;

    String integrationName = 'Order';
    List<String> externalIdList = new List<String>{ '4000' };
    String recordTypeName = 'Inbound';
    String payloadIN = 'Test Payload for Attachment';

    Test.startTest();
    String logId = IntegrationLog.createLog(
      integrationName,
      externalIdList,
      recordTypeName,
      payloadIN,
      '',
      '',
      '',
      200,
      false,
      false,
      testOrder
    );

    IntegrationLog.createAttachment(
      logId,
      'OrderIntegration',
      'Request',
      'ORDER_REQUEST_' + System.now().getTime(),
      System.now().format('yyyy-MM-dd HH:mm:ss'),
      payloadIN
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      logId,
      'Should have created log with attachment'
    );
  }

  @IsTest
  public static void createLogWithHasDeletedTrueTest() {
    TestFactorySObject sobjectFactory = TestFactorySObject.getInstance();
    Order testOrder = (Order) sobjectFactory.createSObject(new Order());
    insert testOrder;

    String integrationName = 'Order';
    List<String> externalIdList = new List<String>{ '5000' };
    String recordTypeName = 'Inbound';
    String payloadIN = 'Request';
    String payloadOUT = 'Response';

    Test.startTest();
    String logId = IntegrationLog.createLog(
      integrationName,
      externalIdList,
      recordTypeName,
      payloadIN,
      payloadOUT,
      '',
      '',
      200,
      false,
      true,
      testOrder
    );
    System.assertNotEquals(null, logId, 'Should handle hasDeleted = true');
    Test.stopTest();
  }

  @IsTest
  public static void createLogWithMultipleErrorsTest() {
    TestFactorySObject sobjectFactory = TestFactorySObject.getInstance();
    Order testOrder = (Order) sobjectFactory.createSObject(new Order());
    insert testOrder;

    String integrationName = 'Order';
    List<String> externalIdList = new List<String>{
      '6000',
      '6001',
      '6002',
      '6003'
    };
    String recordTypeName = 'Inbound';
    String payloadIN = 'Request with multiple items';
    String payloadOUT = 'Response with errors';
    String errorMessage = 'Multiple validation errors detected: Field1 invalid, Field2 missing, Field3 format error';

    Test.startTest();
    String logId = IntegrationLog.createLog(
      integrationName,
      externalIdList,
      recordTypeName,
      payloadIN,
      payloadOUT,
      errorMessage,
      'https://api.example.com',
      400,
      true,
      true,
      testOrder
    );
    System.assertNotEquals(
      null,
      logId,
      'Should create log with multiple errors'
    );
    Test.stopTest();
  }

  @IsTest
  public static void createLogInvalidRecordTypeTest() {
    Test.startTest();
    String logId = IntegrationLog.createLog(
      'Order',
      new List<String>{ '9999' },
      'TIPO_DE_REGISTRO_INEXISTENTE',
      'Test',
      'Test',
      '',
      '',
      200,
      false,
      false,
      null
    );
    Test.stopTest();
  }

  @IsTest
  public static void createLogWithLongExternalIdListTest() {
    List<String> massiveIds = new List<String>();
    for (Integer i = 0; i < 17; i++) {
      massiveIds.add('ID-TEST-1234');
    }

    Test.startTest();
    String logId = IntegrationLog.createLog(
      'Order',
      massiveIds,
      'Inbound',
      'Test',
      'Test',
      '',
      '',
      200,
      false,
      false,
      null
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      logId,
      'The log should have been inserted successfully'
    );

    IntegrationLog__c insertedLog = [
      SELECT ExternalIdList__c
      FROM IntegrationLog__c
      WHERE Id = :logId
      LIMIT 1
    ];
    System.assertNotEquals(null, insertedLog.ExternalIdList__c);
  }

  @IsTest
  public static void createLogExceptionCatchTest() {
    String giantName = 'X'.repeat(100);

    Test.startTest();
    String logId = IntegrationLog.createLog(
      giantName,
      new List<String>{ '123' },
      'Inbound',
      'Test',
      'Test',
      '',
      '',
      200,
      false,
      false,
      null
    );
    Test.stopTest();

    System.assertEquals(
      null,
      logId,
      'The logId should return null due to DML failure contained in the catch'
    );
  }
}
