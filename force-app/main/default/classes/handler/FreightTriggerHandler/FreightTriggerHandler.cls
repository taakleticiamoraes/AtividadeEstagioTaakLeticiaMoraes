public class FreightTriggerHandler {

    public static void handle(List<Freight__c> records){
        FreightService.validateDuplicates(records);
        FreightService.validateObject(records); 
    }
}