public class PricebookService {
  public static Id getStandardPricebookId() {
    if (Test.isRunningTest()) {
      return Test.getStandardPricebookId();
    }
    return [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;
  }

  public static void getOrCreateStandardEntries(Set<Id> productIds) {
    Id pbId = getStandardPricebookId();

    List<PricebookEntry> entriesToInsert = new List<PricebookEntry>();

    for (Id prodId : productIds) {
      entriesToInsert.add(
        new PricebookEntry(
          Pricebook2Id = pbId,
          Product2Id = prodId,
          UnitPrice = 0,
          IsActive = true
        )
      );
    }

    insert entriesToInsert;
  }
}
