public class OrderTriggerHandler {

    public static void run(){

        if(Trigger.isBefore){

            if(Trigger.isInsert){
                OrderService.validateBeforeInsert(
                    (List<Order>) Trigger.new
                );
            }

            if(Trigger.isUpdate){
                OrderService.validateBeforeUpdate(
                    (List<Order>) Trigger.new,
                    (Map<Id, Order>) Trigger.oldMap
                );
            }
        }

        if(Trigger.isAfter && Trigger.isUpdate){
            OrderService.handleAfterUpdate(
                (List<Order>) Trigger.new,
                (Map<Id, Order>) Trigger.oldMap
            );
        }
    }
}