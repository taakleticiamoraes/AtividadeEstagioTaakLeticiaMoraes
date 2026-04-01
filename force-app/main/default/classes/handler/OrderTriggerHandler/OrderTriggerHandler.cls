public class OrderTriggerHandler {

    public static void beforeInsert(List<Order> newList){
        OrderService.validateBeforeInsert(newList);
    }

    public static void beforeUpdate(List<Order> newList, Map<Id, Order> oldMap){
        OrderService.validateBeforeUpdate(newList, oldMap);
    }
}