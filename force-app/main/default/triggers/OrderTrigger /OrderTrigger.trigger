trigger OrderTrigger on Order (before insert, before update, after update) {
    OrderTriggerHandler.run();
}