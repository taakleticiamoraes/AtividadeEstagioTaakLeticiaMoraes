trigger MarginTrigger on Margin__c (before insert, before update) {

    MarginTriggerHandler.run(Trigger.new);
}