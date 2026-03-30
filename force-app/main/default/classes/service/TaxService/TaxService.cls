public class TaxService {
    
    public static void validateDuplicates(List<Tax__c> newList){
        
        Set<String> keys = new Set<String>();
        
        for(Tax__c tax : [
            SELECT Product__c, Distribution_Center__c, State__c
            FROM Tax__c
        ]){
            keys.add(buildKey(tax));
        }
        
        for(Tax__c tax : newList){
            
            String key = buildKey(tax);
            
            if(keys.contains(key)){
                tax.addError('Duplicate tax configuration is not allowed.');
            }
            
            keys.add(key);
        }
    }
    
    private static String buildKey(Tax__c tax){
        return String.valueOf(tax.Product__c) + '-' +
            String.valueOf(tax.Distribution_Center__c) + '-' +
            String.valueOf(tax.State__c);
    }
    
    
    public static void applyTax(List<OrderItem> items){
        
        Set<Id> orderIds = new Set<Id>();
        
        for(OrderItem item : items){
            if(item.OrderId != null){
                orderIds.add(item.OrderId);
            }
        }
        
        Map<Id, Order> orders = new Map<Id, Order>([
            SELECT Id,
                   Distribution_Center__c,
                   Address__r.City__r.State__c
            FROM Order
            WHERE Id IN :orderIds
        ]);
        
        List<Tax__c> taxes = [
            SELECT Id,
                   Product__c,
                   Distribution_Center__c,
                   State__c,
                   Tax_on_cost__c
            FROM Tax__c
            WHERE Status__c = 'Approved'
        ];
        
        for(OrderItem item : items){
            
            Order ord = orders.get(item.OrderId);
            
            if(ord == null){
                item.addError('Order not found.');
                continue;
            }
            
            Id productId = item.Product2Id;
            Id dcId = ord.Distribution_Center__c;
            if(ord.Address__c == null || ord.Address__r.City__r.State__c == null){
                item.addError('Order without complete address.');
                continue;
            }
            Id stateId = ord.Address__r.City__r.State__c;
            
            Integer bestScore = -1;
            Tax__c bestTax;
            
            for(Tax__c tax : taxes){
                
                Integer score = ScoringService.calculateTaxScore(
                    tax, productId, dcId, stateId
                    );
                
                if(score > bestScore && score >= 0){
                    bestScore = score;
                    bestTax = tax;
                }
            }
            
            if(bestTax == null){
                item.addError('No tax found.');
                continue;
            }
            
            item.Tax_Percentage__c = bestTax.Tax_on_cost__c;
        }
    }
}