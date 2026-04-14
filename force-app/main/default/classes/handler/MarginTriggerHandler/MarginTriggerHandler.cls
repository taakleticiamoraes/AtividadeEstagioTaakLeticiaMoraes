public class MarginTriggerHandler {

    public static void run(List<Margin__c> records){
        MarginService.validateDuplicates(records);
        MarginService.validateCategories(records); 
    }
}