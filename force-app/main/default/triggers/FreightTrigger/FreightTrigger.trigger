trigger FreightTrigger on Freight__c (before insert, before update) {

    FreightTriggerHandler.run(Trigger.new);
}