public class OrderItemTriggerHandler {

    public static void beforeInsert(List<OrderItem> newList){
        TaxService.applyTax(newList);
        FreightService.applyFreight(newList);
    }

    public static void beforeUpdate(List<OrderItem> newList){
        TaxService.applyTax(newList);
        FreightService.applyFreight(newList);
    }
}