trigger MarginTrigger on Margin__c (before insert, before update) {

    MarginTriggerHandler.handle(Trigger.new);
}