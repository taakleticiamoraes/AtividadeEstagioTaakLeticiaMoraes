public class MarginTriggerHandler {

    public static void handle(List<Margin__c> records){
        MarginService.validateDuplicates(records);
    }
}