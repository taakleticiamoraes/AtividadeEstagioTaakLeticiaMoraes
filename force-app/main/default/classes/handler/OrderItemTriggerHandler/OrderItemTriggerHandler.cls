public class OrderItemTriggerHandler {
    
    public static void beforeInsert(List<OrderItem> newList){
        process(newList);
    }
    
    public static void beforeUpdate(List<OrderItem> newList){
        process(newList);
    }
    
    private static void process(List<OrderItem> items){
        
        Set<Id> orderIds = new Set<Id>();
        
        for(OrderItem item : items){
            if(item.OrderId != null){
                orderIds.add(item.OrderId);
            }
        }
        
        Map<Id, Order> orders = new Map<Id, Order>([
        SELECT Id, Status
        FROM Order
        WHERE Id IN :orderIds
    ]);
        
        OrderItemService.validateItems(items, orders);
        PricingService.validateRequiredParameters(items);
        
        TaxService.applyTax(items);
        FreightService.applyFreight(items);
        MarginService.applyMargin(items);
        
        PricingService.calculatePricing(items);
    }
}