public class FreightService {
    
    public static void validateObject(List<Freight__c> records){
        
        for(Freight__c freight : records){
            
            CategoryValidation.validateProductCategory(
            freight,
            freight.Product__c,
            freight.Product_Hierarchy__c
                );
            
            CategoryValidation.validateLocationCategory(
                freight,
            freight.City__c,
            freight.State__c,
            freight.Country__c
                );
        }
    }
    
    public static void validateDuplicates(List<Freight__c> records){
        
        Set<String> keys = new Set<String>();
        
        for(Freight__c freight : [
        SELECT Product__c, Product_Hierarchy__c, Distribution_Center__c,
               City__c, State__c, Country__c
        FROM Freight__c
    ]){
            keys.add(buildKey(freight));
        }
        
        for(Freight__c freight : records){
            
            String key = buildKey(freight);
            
            if(keys.contains(key)){
                freight.addError('Duplicate freight configuration.');
            }
            
            keys.add(key);
        }
    }
    
    private static String buildKey(Freight__c freight){
        return String.valueOf(freight.Product__c) + '-' +
            String.valueOf(freight.Product_Hierarchy__c) + '-' +
            String.valueOf(freight.Distribution_Center__c) + '-' +
            String.valueOf(freight.City__c) + '-' +
            String.valueOf(freight.State__c) + '-' +
            String.valueOf(freight.Country__c);
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
        
        set<Id> productIds = new Set<Id>();
        
        for(OrderItem orderItem : items){
            if(orderItem.Product2Id != null){
                productIds.add(orderItem.Product2Id);
            }
        }
        
        Map<Id, Product2> products = new Map<Id, Product2>([
                SELECT Id, Product_Hierarchy__c
                FROM Product2
                WHERE Id IN :productIds
            ]);
        
        for(OrderItem orderItem : items){
            
            Order order = orders.get(orderItem.OrderId);
            
            if(order == null){
                orderItem.addError('Order not found.');
                continue;
            }
            
            if(order.Address__c == null || order.Address__r == null || order.Address__r.City__c == null){
                orderItem.addError('Order without complete address.');
                continue;
            }
            
            Id productId = orderItem.Product2Id;
            Id dcId = order.Distribution_Center__c;
            
            Id cityId = order.Address__r.City__c;
            Id stateId = order.Address__r.City__r.State__c;
            Id countryId = order.Address__r.City__r.State__r.Country__c;
            
            Integer bestScore = -1;
            Freight__c bestFreight;
            
            Product2 prod = products.get(orderItem.Product2Id);
            
            Id hierarchyId;
            
            if(prod != null){
                hierarchyId = prod.Product_Hierarchy__c;
            }
            
            for(Freight__c freight : freights){
                
                Integer score = ScoringService.calculateFreightScore(
                    freight,
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