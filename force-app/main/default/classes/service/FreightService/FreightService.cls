public class FreightService {
    
    public static void validateCategories(List<Freight__c> records){
        
        for(Freight__c f : records){
            
            CategoryValidation.validateProductCategory(
                f,
            f.Product__c,
            f.Product_Hierarchy__c
                );
        }
    }
    
    public static void validateDuplicates(List<Freight__c> records){
        
        Set<String> keys = new Set<String>();
        
        for(Freight__c f : [
        SELECT Product__c, Product_Hierarchy__c, Distribution_Center__c,
               City__c, State__c, Country__c
        FROM Freight__c
    ]){
            keys.add(buildKey(f));
        }
        
        for(Freight__c f : records){
            
            String key = buildKey(f);
            
            if(keys.contains(key)){
                f.addError('Duplicate freight configuration.');
            }
            
            keys.add(key);
        }
    }
    
    private static String buildKey(Freight__c f){
        return String.valueOf(f.Product__c) + '-' +
            String.valueOf(f.Product_Hierarchy__c) + '-' +
            String.valueOf(f.Distribution_Center__c) + '-' +
            String.valueOf(f.City__c) + '-' +
            String.valueOf(f.State__c) + '-' +
            String.valueOf(f.Country__c);
    }
    
    public static void applyFreight(List<OrderItem> items){
        
        Set<Id> orderIds = new Set<Id>();
        
        for(OrderItem item : items){
            if(item.OrderId != null){
                orderIds.add(item.OrderId);
            }
        }
        
        Map<Id, Order> orders = new Map<Id, Order>([
            SELECT Id,
                   Distribution_Center__c,
                   Address__r.City__c,
                   Address__r.City__r.State__c,
                   Address__r.City__r.State__r.Country__c
            FROM Order
            WHERE Id IN :orderIds
        ]);
        
        List<Freight__c> freights = [
            SELECT Id,
                   Product__c,
                   Product_Hierarchy__c,
                   Distribution_Center__c,
                   City__c,
                   State__c,
                   Country__c,
                   Value__c
            FROM Freight__c
            WHERE Status__c = 'Approved'
        ];
        
        for(OrderItem item : items){
            
            Order ord = orders.get(item.OrderId);
            
            if(ord == null){
                item.addError('Order not found.');
                continue;
            }
            
            if(ord.Address__c == null || ord.Address__r == null || ord.Address__r.City__c == null){
                item.addError('Order without complete address.');
                continue;
            }
            
            Id productId = item.Product2Id;
            Id dcId = ord.Distribution_Center__c;
            
            Id cityId = ord.Address__r.City__c;
            Id stateId = ord.Address__r.City__r.State__c;
            Id countryId = ord.Address__r.City__r.State__r.Country__c;
            
            Integer bestScore = -1;
            Freight__c bestFreight;
            
            Set<Id> productIds = new Set<Id>();
            
            for(OrderItem oi : items){
                if(oi.Product2Id != null){
                    productIds.add(oi.Product2Id);
                }
            }
            
            Map<Id, Product2> products = new Map<Id, Product2>([
                SELECT Id, Product_Hierarchy__c
                FROM Product2
                WHERE Id IN :productIds
            ]);
            
            Product2 prod = products.get(item.Product2Id);
            
            Id hierarchyId;
            
            if(prod != null){
                hierarchyId = prod.Product_Hierarchy__c;
            }
            
            for(Freight__c fr : freights){
                
                Integer score = ScoringService.calculateFreightScore(
                    fr,
                productId,
                hierarchyId,
                dcId,
                cityId,
                stateId,
                countryId
                    );
                
                if(score >= 0 && score > bestScore){
                    bestScore = score;
                    bestFreight = fr;
                }
            }
            
            if(bestFreight == null){
                item.addError('No freight found.');
                continue;
            }
            
            item.Shipping_Cost__c = bestFreight.Value__c;
        }
    }
}