public class OrderService {
  public static void validateBeforeInsert(List<Order> newList) {
    for (Order order : newList) {
      // Ensure Total_Discount__c is not set manually on insert
      order.Total_Discount__c = null;
      if (order.AccountId == null) {
        order.addError('Account is required.');
      }

      if (order.Address__c == null) {
        order.addError('Delivery address is required.');
      }

      if (order.Distribution_Center__c == null) {
        order.addError('Distribution Center is required.');
      }

      if (order.Status != 'New') {
        order.Status = 'New';
      }
    }
  }

  public static void validateBeforeUpdate(
    List<Order> newList,
    Map<Id, Order> oldMap
  ) {
    Set<Id> ordersCheckingProducts = new Set<Id>();

    for (Order order : newList) {
      Order old = oldMap.get(order.Id);

      if (!TriggerControl.isRecalculating) {
        Decimal oldDisc = (old.Total_Discount__c == null)
          ? 0
          : old.Total_Discount__c;
        Decimal newDisc = (order.Total_Discount__c == null)
          ? 0
          : order.Total_Discount__c;
        if (newDisc != oldDisc) {
          order.addError(
            'Total Discount is calculated automatically and cannot be changed manually.'
          );
        }
      }

      if (order.AccountId != old.AccountId) {
        order.addError('Account cannot be changed after order creation.');
      }

      if (old.Status == 'Integrated' && !TriggerControl.ignoreActivatedCheck) {
        order.addError('Cannot update an activated order.');
      }

      if (old.Status != 'Integrated' && order.Status == 'Integrated') {
        validateActivation(order);
      }

      // If in "Integration error" and any field changed (except Status), reset to "New"
      if (
        old.Status == 'Integration error' &&
        order.Status == 'Integration error'
      ) {
        // Comparar sem considerar o campo Status
        Order oldClone = old.clone(false, false);
        Order newClone = order.clone(false, false);
        oldClone.Status = null;
        newClone.Status = null;

        String oldJson = JSON.serialize(oldClone);
        String newJson = JSON.serialize(newClone);

        if (oldJson != newJson) {
          order.Status = 'New';
          System.debug(
            'Order ' +
              order.Id +
              ' was reset to "New" because fields were modified'
          );
        }
      }

      /* --- STATUS VALIDATION ALIGNED WITH ORG --- */
      if (order.Status != old.Status) {
        String oldStatus = old.Status.toLowerCase();
        String newStatus = order.Status.toLowerCase();

        // 1. Allowed transition: User submits for approval
        if (oldStatus == 'new' && newStatus == 'pending approval') {
          ordersCheckingProducts.add(order.Id);

          // 2. Allowed transition: Automations advancing to Approved (Flow/Approval Process)
        } else if (oldStatus == 'pending approval' && newStatus == 'approved') {
          // Let Apex proceed. An Org Validation Rule ensures users cannot do this manually.

          // 3. Allowed transition: Manager rejecting the order (Back to New)
        } else if (oldStatus == 'pending approval' && newStatus == 'new') {
          // Let Apex proceed.

          // 4. Allowed transition: Manual reset from Integration error to New
        } else if (oldStatus == 'integration error' && newStatus == 'new') {
          // Let Apex proceed. User may reset manually.

          // 5. Allowed transition: Integration running via system code
        } else if (TriggerControl.ignoreActivatedCheck) {
          // Allow freely when integration is running

          // Residual manual security locks:
        } else if (order.Status == 'Integrated') {
          order.addError(
            'You cannot manually change the status to Integrated.'
          );
        } else {
          order.addError(
            'The only allowed status change is from New to Pending approval.'
          );
        }
      }
    }

    if (!ordersCheckingProducts.isEmpty()) {
      Set<Id> ordersWithItems = new Set<Id>();
      for (AggregateResult ar : [
        SELECT OrderId
        FROM OrderItem
        WHERE OrderId IN :ordersCheckingProducts
        GROUP BY OrderId
      ]) {
        ordersWithItems.add((Id) ar.get('OrderId'));
      }

      for (Order order : newList) {
        if (
          ordersCheckingProducts.contains(order.Id) &&
          !ordersWithItems.contains(order.Id)
        ) {
          order.addError(
            'Cannot submit to Approval without any order products.'
          );
        }
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
        Quantity,
        Discount__c
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

    // Calculate weighted average discount per order by quantity:
    // avg = SUM(Discount__c * Quantity) / SUM(Quantity)
    Map<Id, Decimal> sumDQ = new Map<Id, Decimal>();
    Map<Id, Decimal> sumQ = new Map<Id, Decimal>();

    for (OrderItem it : items) {
      if (it.OrderId == null)
        continue;
      Decimal d = (it.Discount__c == null) ? 0 : it.Discount__c;
      Decimal q = (it.Quantity == null) ? 0 : it.Quantity;
      Decimal dTimesQ = d * q;

      sumDQ.put(
        it.OrderId,
        (sumDQ.containsKey(it.OrderId) ? sumDQ.get(it.OrderId) : 0) + dTimesQ
      );
      sumQ.put(
        it.OrderId,
        (sumQ.containsKey(it.OrderId) ? sumQ.get(it.OrderId) : 0) + q
      );
    }

    List<Order> ordersToUpdate = new List<Order>();
    for (Id oid : sumQ.keySet()) {
      Decimal totalQty = sumQ.get(oid);
      if (totalQty == null || totalQty == 0)
        continue;

      Decimal weightedSum = (sumDQ.containsKey(oid) ? sumDQ.get(oid) : 0);
      Decimal avg = weightedSum / totalQty;
      Order o = new Order(Id = oid);
      o.Total_Discount__c = avg.setScale(2);
      ordersToUpdate.add(o);
    }

    if (!ordersToUpdate.isEmpty()) {
      update ordersToUpdate;
    }

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

      if (old.Status != 'Approved' && order.Status == 'Approved') {
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

      System.debug(
        'OrderService.integrateOrders: response = ' + JSON.serialize(response)
      );
      System.debug(
        'OrderService.integrateOrders: response.hasError = ' +
        (response != null ? String.valueOf(response.hasError) : 'null')
      );
      System.debug('OrderService.integrateOrders: orderIds = ' + orderIds);

      // Build a unified list of response wrappers (supports single or multiple)
      List<DataIntegrationFields.ResponseParametersWrapper> responseList = new List<DataIntegrationFields.ResponseParametersWrapper>();
      if (response == null) {
        // nothing
      } else if (response.parsedResponses != null) {
        responseList = response.parsedResponses;
      } else if (response.parsedResponse != null) {
        responseList.add(response.parsedResponse);
      }

      System.debug(
        'OrderService.integrateOrders: responseList size = ' +
        responseList.size()
      );
      System.debug(
        'OrderService.integrateOrders: responseList = ' +
        JSON.serialize(responseList)
      );

      List<Order> ordersToUpdate = new List<Order>();

      if (!responseList.isEmpty()) {
        // Map externalIds to response wrappers
        Set<String> externalIds = new Set<String>();
        for (DataIntegrationFields.ResponseParametersWrapper r : responseList) {
          if (r.externalId != null)
            externalIds.add(r.externalId);
        }

        System.debug(
          'OrderService.integrateOrders: externalIds = ' + externalIds
        );

        if (!externalIds.isEmpty()) {
          Map<String, Order> ordersByExternal = new Map<String, Order>();
          for (Order o : [
            SELECT Id, ExternalId__c, Status
            FROM Order
            WHERE ExternalId__c IN :externalIds
          ]) {
            ordersByExternal.put(o.ExternalId__c, o);
          }

          System.debug(
            'OrderService.integrateOrders: ordersByExternal size = ' +
            ordersByExternal.size()
          );

          for (
            DataIntegrationFields.ResponseParametersWrapper r : responseList
          ) {
            String ext = r.externalId;
            if (ext == null)
              continue;
            Order base = ordersByExternal.get(ext);
            System.debug(
              'OrderService.integrateOrders: Processing externalId=' +
                ext +
                ', order found=' +
                (base != null)
            );
            if (base == null)
              continue;

            String newStatus = (r.hasError
              ? 'Integration Error'
              : 'Integrated');
            System.debug(
              'OrderService.integrateOrders: Setting status from ' +
                base.Status +
                ' to ' +
                newStatus +
                ' for order ' +
                base.Id
            );

            // If child items contain errors, mark as error as well
            if (!r.hasError && r.items != null) {
              for (
                DataIntegrationFields.ResponseParametersWrapper item : r.items
              ) {
                if (item.hasError) {
                  newStatus = 'Integration Error';
                  break;
                }
              }
            }

            ordersToUpdate.add(new Order(Id = base.Id, Status = newStatus));
          }
        }
      } else if (response != null && response.hasError) {
        for (Order o : [SELECT Id FROM Order WHERE Id IN :orderIds]) {
          ordersToUpdate.add(
            new Order(Id = o.Id, Status = 'Integration Error')
          );
        }
      } else if (response != null && !response.hasError) {
        for (Order o : [SELECT Id FROM Order WHERE Id IN :orderIds]) {
          ordersToUpdate.add(new Order(Id = o.Id, Status = 'Integrated'));
        }
        System.debug(
          'OrderService.integrateOrders: Marked orders as Integrated due to successful response with empty responseList'
        );
      }

      System.debug(
        'OrderService.integrateOrders: ordersToUpdate size = ' +
        ordersToUpdate.size()
      );

      if (!ordersToUpdate.isEmpty()) {
        TriggerControl.ignoreActivatedCheck = true;
        try {
          update ordersToUpdate;
          System.debug(
            'OrderService.integrateOrders: Successfully updated ' +
              ordersToUpdate.size() +
              ' orders'
          );
        } catch (Exception updateEx) {
          System.debug(
            'OrderService.integrateOrders: Failed to update orders: ' +
              updateEx.getMessage() +
              ' - ' +
              updateEx.getStackTraceString()
          );
        } finally {
          TriggerControl.ignoreActivatedCheck = false;
        }
      }

      if (response != null && response.hasError) {
        String msgError = String.isBlank(response.errorMessage)
          ? CalloutOrder.handlerError(response)
          : response.errorMessage;

        System.debug('Failure in asynchronous integration: ' + msgError);
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
