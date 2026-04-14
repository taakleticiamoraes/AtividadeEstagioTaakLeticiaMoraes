public class OrderItemTriggerHandler {
    
    public static void run(List<OrderItem> newList, Map<Id, OrderItem> oldMap) {
        
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                beforeInsert(newList);
            }
            else if(Trigger.isUpdate){
                beforeUpdate(newList, oldMap);
            }
        }
    }
    
    public static void beforeInsert(List<OrderItem> newList){
        processBefore(newList);
    }
    
    public static void beforeUpdate(List<OrderItem> newList, Map<Id, OrderItem> oldMap){
        processBefore(newList);
    }
    
    private static void processBefore(List<OrderItem> items){
        
        Set<Id> orderIds = new Set<Id>();
        
        for(OrderItem item : items){
            if(item.OrderId != null){
                orderIds.add(item.OrderId);
                System.debug(item);
            }

        }
        
        Map<Id, Order> orders = new Map<Id, Order>([
            SELECT Id, Status
            FROM Order
            WHERE Id IN :orderIds
        ]);
        
        OrderItemService.validateItems(items, orders);
        
        TaxService.applyTax(items);
        FreightService.applyFreight(items);
        MarginService.applyMargin(items);
        
        PricingService.calculatePricing(items);
        PricingService.validateRequiredParameters(items);
    }
}