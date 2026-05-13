public class OrderService {
  public static void validateBeforeInsert(List<Order> newList) {
    for (Order order : newList) {
      if (order.AccountId == null) {
        order.addError('Account is required.');
      }

      if (order.Address__c == null) {
        order.addError('Delivery address is required.');
      }

      if (order.Distribution_Center__c == null) {
        order.addError('Distribution Center is required.');
      }
    }
  }

  public static void validateBeforeUpdate(
    List<Order> newList,
    Map<Id, Order> oldMap
  ) {
    for (Order order : newList) {
      Order old = oldMap.get(order.Id);

      if (order.AccountId != old.AccountId) {
        order.addError('Account cannot be changed after order creation.');
      }

      if (old.Status == 'Activated' && !TriggerControl.ignoreActivatedCheck) {
        order.addError('Cannot update an activated order.');
      }

      if (old.Status != 'Activated' && order.Status == 'Activated') {
        validateActivation(order);
      }
    }
  }

  public static void recalculateOrderItems(Set<Id> orderIds) {
    if (TriggerControl.isRecalculating)
      return;

    TriggerControl.isRecalculating = true;

    List<OrderItem> items = [
      SELECT
        Id,
        OrderId,
        Product2Id,
        Production_Cost__c,
        Shipping_Cost__c,
        Tax_Percentage__c,
        Margin_Percentage__c,
        Selling_Price__c,
        Quantity
      FROM OrderItem
      WHERE OrderId IN :orderIds
    ];

    if (items.isEmpty()) {
      TriggerControl.isRecalculating = false;
      return;
    }

    TaxService.applyTax(items);
    FreightService.applyFreight(items);
    MarginService.applyMargin(items);

    PricingService.calculatePricing(items);

    update items;

    TriggerControl.isRecalculating = false;
  }

  @TestVisible
  static void validateActivationItems(List<OrderItem> items) {
    for (OrderItem item : items) {
      if (item.Quantity <= 0) {
        item.addError('All items must have quantity greater than zero.');
      }

      if (item.Selling_Price__c <= 0) {
        item.addError('All items must have a valid selling price.');
      }
    }
  }

  private static void validateActivation(Order order) {
    if (order.Address__c == null) {
      order.addError('Cannot activate order without address.');
    }

    if (order.Distribution_Center__c == null) {
      order.addError('Cannot activate order without distribution center.');
    }

    List<OrderItem> items = [
      SELECT Id, Quantity, Selling_Price__c
      FROM OrderItem
      WHERE OrderId = :order.Id
    ];

    if (items.isEmpty()) {
      order.addError('Cannot activate order without items.');
    }

    validateActivationItems(items);
  }

  public static void handleAfterUpdate(
    List<Order> newList,
    Map<Id, Order> oldMap
  ) {
    Set<Id> ordersToRecalculate = new Set<Id>();
    List<String> ordersToIntegrate = new List<String>();

    for (Order order : newList) {
      Order old = oldMap.get(order.Id);

      if (
        order.Address__c != old.Address__c ||
        order.Distribution_Center__c != old.Distribution_Center__c ||
        order.Status != old.Status
      ) {
        ordersToRecalculate.add(order.Id);
      }

      if (old.Status != 'Activated' && order.Status == 'Activated') {
        ordersToIntegrate.add((String) order.Id);
      }
    }

    if (!ordersToRecalculate.isEmpty()) {
      recalculateOrderItems(ordersToRecalculate);
    }

    if (!ordersToIntegrate.isEmpty()) {
      integrateOrders(ordersToIntegrate);
    }
  }

  @future(callout=true)
  public static void integrateOrders(List<String> orderIds) {
    try {
      DataIntegrationFields.CalloutResponse response = CalloutOrder.executeCalloutOrder(
        orderIds
      );

      if (response.hasError) {
        String msgErro = String.isBlank(response.errorMessage)
          ? CalloutOrder.handlerError(response)
          : response.errorMessage;

        System.debug('Failure in asynchronous integration: ' + msgErro);
      } else {
        System.debug(
          'Success in asynchronous integration of Orders: ' + orderIds
        );
      }
    } catch (Exception e) {
      System.debug(
        'Fatal error in asynchronous integration: ' +
          e.getMessage() +
          ' - ' +
          e.getStackTraceString()
      );
    }
  }
}
