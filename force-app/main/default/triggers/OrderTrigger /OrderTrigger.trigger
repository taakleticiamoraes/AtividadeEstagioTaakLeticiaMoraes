trigger OrderTrigger on Order (before insert, before update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            OrderTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            OrderTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}