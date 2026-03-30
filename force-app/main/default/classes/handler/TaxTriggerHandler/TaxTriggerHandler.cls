public class TaxTriggerHandler {
    
    public static void handle(List<Tax__c> records){
        TaxService.validateDuplicates(records);
    }
}