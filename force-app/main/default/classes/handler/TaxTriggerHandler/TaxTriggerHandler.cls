public class TaxTriggerHandler {

    public static void validateDuplicates(List<Tax__c> newList){

        Set<String> keys = new Set<String>();

        for(Tax__c tax : newList){
            String key = tax.Product__c + '-' +
                         tax.Distribution_Center__c + '-' +
                         tax.State__c;
            keys.add(key);
        }

        List<Tax__c> existing = [
            SELECT Id, Product__c, Distribution_Center__c, State__c
            FROM Tax__c
            WHERE Status__c = 'Approved'
        ];

        Set<String> existingKeys = new Set<String>();

        for(Tax__c tax : existing){
            String key = tax.Product__c + '-' +
                         tax.Distribution_Center__c + '-' +
                         tax.State__c;
            existingKeys.add(key);
        }

        for(Tax__c tax : newList){

            String key = tax.Product__c + '-' +
                         tax.Distribution_Center__c + '-' +
                         tax.State__c;

            if(existingKeys.contains(key)){
                tax.addError('Duplicate tax configuration is not allowed.');
            }
        }
    }
}