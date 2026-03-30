trigger TaxTrigger on Tax__c (before insert, before update) {
    
    TaxTriggerHandler.handle(Trigger.new);
}