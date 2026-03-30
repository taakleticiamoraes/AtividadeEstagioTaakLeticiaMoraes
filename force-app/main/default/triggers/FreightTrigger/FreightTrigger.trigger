trigger FreightTrigger on Freight__c (before insert, before update) {

    FreightTriggerHandler.handle(Trigger.new);
}