public with sharing class InvocableOrderIntegration {
  @AuraEnabled
  public static void runIntegrationFromLWC(Id orderId) {
    if (orderId == null)
      return;

    List<String> idsAsStrings = new List<String>{ String.valueOf(orderId) };

    OrderService.integrateOrders(idsAsStrings);
  }
}
