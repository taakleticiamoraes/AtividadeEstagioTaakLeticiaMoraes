trigger OrderItemTrigger on OrderItem (before insert, before update) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            OrderItemTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            OrderItemTriggerHandler.beforeUpdate(Trigger.new);
        }
    }
}