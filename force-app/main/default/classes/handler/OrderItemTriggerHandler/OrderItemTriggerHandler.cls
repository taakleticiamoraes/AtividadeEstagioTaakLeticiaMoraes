public class OrderItemTriggerHandler {

    public static void beforeInsert(List<OrderItem> newList){
        process(newList);
    }

    public static void beforeUpdate(List<OrderItem> newList){
        process(newList);
    }

    private static void process(List<OrderItem> items){

        TaxService.applyTax(items);
        FreightService.applyFreight(items);
        MarginService.applyMargin(items);
        PricingService.validateRequiredParameters(items);
        PricingService.calculatePricing(items);
    }
}