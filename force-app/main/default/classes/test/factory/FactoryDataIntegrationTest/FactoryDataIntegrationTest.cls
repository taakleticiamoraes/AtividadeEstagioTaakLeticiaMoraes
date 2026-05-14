@isTest
private class FactoryDataIntegrationTest {
  private static String getFakeId(SObjectType sObjectType) {
    String prefix = sObjectType.getDescribe().getKeyPrefix();
    return prefix + '000000000001AAA';
  }

  @isTest
  static void testConvertSObjectSuccess() {
    DataIntegrationFields.OrderINData mockOrderData = new DataIntegrationFields.OrderINData();
    mockOrderData.externalId = 'EXT_ORD_001';
    mockOrderData.status = 'Draft';
    mockOrderData.effectiveDate = String.valueOf(Date.today());
    mockOrderData.shippingType = 'CIF';

    List<DataIntegrationFields.FieldData> fieldDataList = new List<DataIntegrationFields.FieldData>{
      mockOrderData
    };
    List<DataIntegrationFields.Response> responseList = new List<DataIntegrationFields.Response>();
    List<SObject> listToUpsert = new List<SObject>();

    Test.startTest();
    String externalIds = FactoryDataIntegration.convertSObject(
      new Order(),
      'IN',
      fieldDataList,
      responseList,
      listToUpsert
    );
    Test.stopTest();

    System.assertEquals(
      'EXT_ORD_001',
      externalIds,
      'Should return the processed External IDs.'
    );
    System.assertEquals(
      1,
      listToUpsert.size(),
      'The valid deserialized object should be added to the upsert list.'
    );
    System.assertEquals(
      0,
      responseList.size(),
      'There should be no errors in the response list.'
    );

    Order castedOrder = (Order) listToUpsert[0];
    System.assertEquals(
      'EXT_ORD_001',
      castedOrder.ExternalId__c,
      'The mapped ExternalId on the SObject must be identical.'
    );
  }

  @isTest
  static void testConvertSObjectInvalidClassException() {
    List<DataIntegrationFields.FieldData> fieldDataList = new List<DataIntegrationFields.FieldData>();
    List<DataIntegrationFields.Response> responseList = new List<DataIntegrationFields.Response>();
    List<SObject> listToUpsert = new List<SObject>();

    Test.startTest();
    try {
      FactoryDataIntegration.convertSObject(
        new Order(),
        'XYZ',
        fieldDataList,
        responseList,
        listToUpsert
      );
      System.assert(
        false,
        'Should have thrown a FactoryDataIntegrationException.'
      );
    } catch (FactoryDataIntegration.FactoryDataIntegrationException e) {
      System.assertEquals(
        'Invalid defaults class.',
        e.getMessage(),
        'The exception error message is incorrect.'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testValidateObjectWithError() {
    Order invalidOrder = new Order(ExternalId__c = 'EXT_ERR_001');

    List<SObject> listToUpsert = new List<SObject>();
    List<DataIntegrationFields.Response> responseList = new List<DataIntegrationFields.Response>();

    List<String> requiredFields = new List<String>{
      'ExternalId__c',
      'EffectiveDate',
      'Status'
    };

    Test.startTest();
    FactoryDataIntegration.validateObject(
      'Id',
      'ExternalId__c',
      invalidOrder,
      listToUpsert,
      responseList,
      requiredFields
    );
    Test.stopTest();

    System.assertEquals(
      0,
      listToUpsert.size(),
      'An invalid record must NOT be added to the upsert list.'
    );
    System.assertEquals(
      1,
      responseList.size(),
      'Should add an error response.'
    );
    System.assertEquals(
      true,
      responseList[0].hasError,
      'The hasError flag must be set to true.'
    );
    System.assert(
      responseList[0]
        .errorMessage.contains('Invalid value for the required field.'),
      'Incorrect validation message.'
    );
  }

  @isTest
  static void testConvertSObjectChildSuccess() {
    DataIntegrationFields.OrderItemINData mockItemData = new DataIntegrationFields.OrderItemINData();
    mockItemData.externalId = 'EXT_ITEM_001';
    mockItemData.orderExternalId = 'EXT_ORD_001';
    mockItemData.quantity = 5;
    mockItemData.unitPrice = 150.00;
    mockItemData.sellingPrice = 150.00;
    mockItemData.productionCost = 70.00;

    List<DataIntegrationFields.FieldDataChild> fieldDataList = new List<DataIntegrationFields.FieldDataChild>{
      mockItemData
    };
    Map<String, List<DataIntegrationFields.Response>> responseMap = new Map<String, List<DataIntegrationFields.Response>>();
    List<SObject> listToUpsert = new List<SObject>();

    Test.startTest();
    FactoryDataIntegration.convertSObjectChild(
      new OrderItem(),
      'IN',
      fieldDataList,
      responseMap,
      listToUpsert
    );
    Test.stopTest();

    System.assertEquals(
      1,
      listToUpsert.size(),
      'The deserialized order item should be added to the upsert list.'
    );
    System.assertEquals(
      0,
      responseMap.size(),
      'The error map should remain empty.'
    );

    OrderItem castedItem = (OrderItem) listToUpsert[0];
    System.assertEquals(
      5,
      castedItem.Quantity,
      'The mapped quantity is incorrect.'
    );
  }

  @isTest
  static void testValidateObjectChildWithError() {
    OrderItem invalidItem = new OrderItem(ExternalId__c = 'EXT_ITEM_ERR');

    DataIntegrationFields.OrderItemINData mockItemData = new DataIntegrationFields.OrderItemINData();
    mockItemData.orderExternalId = 'PARENT_ORD_KEY';

    List<SObject> listToUpsert = new List<SObject>();
    Map<String, List<DataIntegrationFields.Response>> responseMap = new Map<String, List<DataIntegrationFields.Response>>();
    List<String> requiredFields = new List<String>{ 'UnitPrice', 'Quantity' };

    Test.startTest();
    FactoryDataIntegration.validateObjectChild(
      mockItemData,
      'ExternalId__c',
      invalidItem,
      listToUpsert,
      requiredFields,
      responseMap
    );
    Test.stopTest();

    System.assertEquals(
      0,
      listToUpsert.size(),
      'An invalid item must not be added to the upsert list.'
    );
    System.assertEquals(
      true,
      responseMap.containsKey('PARENT_ORD_KEY'),
      'The error should be cataloged under the Parent Order external key.'
    );
    System.assertEquals(
      1,
      responseMap.get('PARENT_ORD_KEY').size(),
      'There should be exactly one error for this parent.'
    );
  }

  @isTest
  static void testConvertSObjectMultipleItemsConcatenation() {
    DataIntegrationFields.OrderINData item1 = new DataIntegrationFields.OrderINData();
    item1.externalId = 'ORD1';
    item1.status = 'Draft';
    item1.effectiveDate = String.valueOf(Date.today());

    DataIntegrationFields.OrderINData item2 = new DataIntegrationFields.OrderINData();
    item2.externalId = 'ORD2';
    item2.status = 'Draft';
    item2.effectiveDate = String.valueOf(Date.today());

    List<DataIntegrationFields.FieldData> fieldDataList = new List<DataIntegrationFields.FieldData>{
      item1,
      item2
    };

    Test.startTest();
    String externalIds = FactoryDataIntegration.convertSObject(
      new Order(),
      'IN',
      fieldDataList,
      new List<DataIntegrationFields.Response>(),
      new List<SObject>()
    );
    Test.stopTest();

    System.assertEquals('ORD1, ORD2', externalIds);
  }

  @isTest
  static void testValidateObjectWithErrorAndExistingId() {
    Id fakeOrderId = getFakeId(Order.SObjectType);
    Order recordWithId = new Order(Id = fakeOrderId, ExternalId__c = 'EXT1');

    List<SObject> listToUpsert = new List<SObject>();
    List<DataIntegrationFields.Response> responseList = new List<DataIntegrationFields.Response>();
    List<String> requiredFields = new List<String>{ 'Status' };

    Test.startTest();
    FactoryDataIntegration.validateObject(
      'Id',
      'ExternalId__c',
      recordWithId,
      listToUpsert,
      responseList,
      requiredFields
    );
    Test.stopTest();

    System.assertEquals(1, responseList.size());
    System.assertEquals(fakeOrderId, responseList[0].salesforceId);
  }

  @isTest
  static void testConvertSObjectChildWithFieldIdPopulated() {
    DataIntegrationFields.OrderItemINData itemData = new DataIntegrationFields.OrderItemINData();
    itemData.id = getFakeId(OrderItem.SObjectType);
    itemData.externalId = 'ITEM1';
    itemData.quantity = 1;
    itemData.unitPrice = 10;
    itemData.orderExternalId = 'ORD1';

    List<DataIntegrationFields.FieldDataChild> fieldDataList = new List<DataIntegrationFields.FieldDataChild>{
      itemData
    };

    Test.startTest();
    FactoryDataIntegration.convertSObjectChild(
      new OrderItem(),
      'IN',
      fieldDataList,
      new Map<String, List<DataIntegrationFields.Response>>(),
      new List<SObject>()
    );
    Test.stopTest();

    System.assert(
      true,
      'Method should complete without exceptions using a populated ID.'
    );
  }

  @isTest
  static void testConvertSObjectThrowException() {
    List<DataIntegrationFields.FieldData> fieldDataList = new List<DataIntegrationFields.FieldData>();

    Test.startTest();
    try {
      FactoryDataIntegration.convertSObject(
        new Order(),
        'Unknown',
        fieldDataList,
        new List<DataIntegrationFields.Response>(),
        new List<SObject>()
      );
      System.assert(
        false,
        'Exception should have been thrown for invalid service'
      );
    } catch (FactoryDataIntegration.FactoryDataIntegrationException e) {
      System.assertEquals('Invalid defaults class.', e.getMessage());
    }
    Test.stopTest();
  }

  @isTest
  static void testConvertSObjectChildThrowException() {
    List<DataIntegrationFields.FieldDataChild> fieldDataList = new List<DataIntegrationFields.FieldDataChild>();

    Test.startTest();
    try {
      FactoryDataIntegration.convertSObjectChild(
        new OrderItem(),
        'Unknown',
        fieldDataList,
        new Map<String, List<DataIntegrationFields.Response>>(),
        new List<SObject>()
      );
      System.assert(
        false,
        'Exception should have been thrown for invalid service in Child method'
      );
    } catch (FactoryDataIntegration.FactoryDataIntegrationException e) {
      System.assertEquals('Invalid defaults class.', e.getMessage());
    }
    Test.stopTest();
  }
}
