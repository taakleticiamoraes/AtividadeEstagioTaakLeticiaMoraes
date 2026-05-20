@IsTest
public class PricebookServiceTest {
  @TestSetup
  public static void makeData() {
    Long timestamp = System.currentTimeMillis();

    Product2 product1 = (Product2) TestFactorySObject.getInstance()
      .createSObject(new Product2());

    product1.Name = 'Test Product 1 ' + timestamp;
    product1.ExternalId__c = 'PROD-1-' + timestamp;
    product1.IsActive = true;

    Product2 product2 = (Product2) TestFactorySObject.getInstance()
      .createSObject(new Product2());

    product2.Name = 'Test Product 2 ' + timestamp;
    product2.ExternalId__c = 'PROD-2-' + timestamp;
    product2.IsActive = true;

    insert new List<Product2>{ product1, product2 };
  }

  @IsTest
  static void testGetStandardPricebookId() {
    Test.startTest();

    Id standardPbId = PricebookService.getStandardPricebookId();

    Test.stopTest();

    System.assertNotEquals(null, standardPbId);
  }

  @IsTest
  static void testGetOrCreateStandardEntries() {
    List<Product2> products = [
      SELECT Id
      FROM Product2
    ];

    Set<Id> productIds = new Set<Id>();

    for (Product2 prod : products) {
      productIds.add(prod.Id);
    }

    Id standardPbId = Test.getStandardPricebookId();

    // Remove entries created by the trigger
    List<PricebookEntry> existingEntries = [
      SELECT Id
      FROM PricebookEntry
      WHERE Product2Id IN :productIds AND Pricebook2Id = :standardPbId
    ];

    delete existingEntries;

    Test.startTest();

    PricebookService.getOrCreateStandardEntries(productIds);

    Test.stopTest();

    List<PricebookEntry> entries = [
      SELECT Id, Product2Id, Pricebook2Id, UnitPrice, IsActive
      FROM PricebookEntry
      WHERE Product2Id IN :productIds AND Pricebook2Id = :standardPbId
    ];

    System.assertEquals(products.size(), entries.size());

    for (PricebookEntry entry : entries) {
      System.assertEquals(0, entry.UnitPrice);
      System.assertEquals(true, entry.IsActive);
    }
  }
}
