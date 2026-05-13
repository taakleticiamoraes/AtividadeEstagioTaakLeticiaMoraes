public class ProductTriggerHandler {
  public static void onAfterInsert(List<Product2> newProducts) {
    handlePricebook(newProducts);
  }

  private static void handlePricebook(List<Product2> products) {
    Set<Id> productIds = new Set<Id>();

    for (Product2 p : products) {
      productIds.add(p.Id);
    }

    PricebookService.getOrCreateStandardEntries(productIds);
  }
}
