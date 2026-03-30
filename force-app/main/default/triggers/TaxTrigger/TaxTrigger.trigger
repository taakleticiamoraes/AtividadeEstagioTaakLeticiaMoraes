trigger TaxTrigger on Tax__c (before insert, before update) {

    if(Trigger.isBefore){
        TaxTriggerHandler.validateDuplicates(Trigger.new);
    }
}