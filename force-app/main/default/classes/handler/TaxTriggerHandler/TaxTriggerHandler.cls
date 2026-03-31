public class TaxTriggerHandler {
    
    public static void handle(List<Tax__c> records){
        TaxService.validateCategories(records);
        TaxService.validateDuplicates(records);
    }
}