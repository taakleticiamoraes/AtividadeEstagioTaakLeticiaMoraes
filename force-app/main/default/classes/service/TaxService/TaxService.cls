public class TaxService {
    public static void validateCategories(List<Tax__c> records){
        
        for(Tax__c tax : records){
            
            if(tax.Product__c == null){
                tax.addError('Product is required.');
            }
            
            if(tax.Distribution_Center__c == null){
                tax.addError('Distribution Center is required.');
            }
            
            if(tax.State__c == null){
                tax.addError('State is required.');
            }
        }
    }
    
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
            
            Order order = orders.get(item.OrderId);
            
            if(order == null){
                item.addError('Order not found.');
                continue;
            }
            
            Id productId = item.Product2Id;
            Id dcId = order.Distribution_Center__c;
            if(order.Address__c == null || order.Address__r.City__r.State__c == null){
                item.addError('Order without complete address.');
                continue;
            }
            Id stateId = order.Address__r.City__r.State__c;
            
            
            Integer bestScore = -1;
            Tax__c bestTax;
            
            for(Tax__c tax : taxes){
                if(tax.Product__c == productId){
                    if(tax.Distribution_Center__c == dcId){
                        if(tax.State__c == stateId){
                                item.Tax_Percentage__c = tax.Tax_on_cost__c;
                        }
                    }
                }
                if(tax.State__c != stateId){
                    continue;
                }
            }
        }
    }
}