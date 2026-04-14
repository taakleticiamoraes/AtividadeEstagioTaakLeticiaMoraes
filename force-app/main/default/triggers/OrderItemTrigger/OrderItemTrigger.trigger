trigger OrderItemTrigger on OrderItem (before insert, before update) {
    OrderItemTriggerHandler.run(Trigger.new, Trigger.oldMap);
}