public class MarginService {
    
    public static void validateDuplicates(List<Margin__c> records){
        
        Set<String> keys = new Set<String>();
        
        for(Margin__c m : [
        SELECT Product__c, Product_Hierarchy__c,
               Account__c, Group_Account__c,
               City__c, State__c, Country__c
        FROM Margin__c
    ]){
            keys.add(buildKey(m));
        }
        
        for(Margin__c m : records){
            
            if(m.Product__c != null && m.Product_Hierarchy__c != null){
                m.addError('Cannot fill both Product and Hierarchy.');
            }
            
            if(m.Account__c != null && m.Group_Account__c != null){
                m.addError('Cannot fill both Account and Group.');
            }
            
            String key = buildKey(m);
            
            if(keys.contains(key)){
                m.addError('Duplicate margin configuration.');
            }
            
            keys.add(key);
        }
    }
    
    private static String buildKey(Margin__c m){
        return String.valueOf(m.Product__c) + '-' +
            String.valueOf(m.Product_Hierarchy__c) + '-' +
            String.valueOf(m.Account__c) + '-' +
            String.valueOf(m.Group_Account__c) + '-' +
            String.valueOf(m.City__c) + '-' +
            String.valueOf(m.State__c) + '-' +
            String.valueOf(m.Country__c);
    }
    
    public static void applyMargin(List<OrderItem> items){
        
        Set<Id> orderIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        for(OrderItem item : items){
            if(item.OrderId != null) orderIds.add(item.OrderId);
            if(item.Product2Id != null) productIds.add(item.Product2Id);
        }
        
        Map<Id, Order> orders = new Map<Id, Order>([
            SELECT Id,
                   AccountId,
                   Distribution_Center__c,
                   Address__r.City__c,
                   Address__r.City__r.State__c,
                   Address__r.City__r.State__r.Country__c
            FROM Order
            WHERE Id IN :orderIds
        ]);
        
        for(Order o : orders.values()){
            if(o.AccountId != null){
                accountIds.add(o.AccountId);
            }
        }
        
        Map<Id, Account> accounts = new Map<Id, Account>([
            SELECT Id, Group_Account__c
            FROM Account
            WHERE Id IN :accountIds
        ]);
        
        Map<Id, Product2> products = new Map<Id, Product2>([
            SELECT Id, Product_Hierarchy__c
            FROM Product2
            WHERE Id IN :productIds
        ]);
        
        List<Margin__c> margins = [
            SELECT Id,
                   Product__c,
                   Product_Hierarchy__c,
                   Account__c,
                   Group_Account__c,
                   City__c,
                   State__c,
                   Country__c,
                   Value__c
            FROM Margin__c
            WHERE Status__c = 'Approved'
        ];
        
        for(OrderItem item : items){
            
            Order ord = orders.get(item.OrderId);
            if(ord == null){
                item.addError('Order not found.');
                continue;
            }
            
            if(ord.Address__c == null || ord.Address__r == null){
                item.addError('Order without address.');
                continue;
            }
            
            Product2 prod = products.get(item.Product2Id);
            Account acc = accounts.get(ord.AccountId);
            
            Id hierarchyId = (prod != null) ? prod.Product_Hierarchy__c : null;
            Id groupAccountId = (acc != null) ? acc.Group_Account__c : null;
            
            Id cityId = ord.Address__r.City__c;
            Id stateId = ord.Address__r.City__r.State__c;
            Id countryId = ord.Address__r.City__r.State__r.Country__c;
            
            Integer bestScore = -1;
            Margin__c bestMargin;
            
            for(Margin__c m : margins){
                
                Integer score = ScoringService.calculateMarginScore(
                    m,
                item.Product2Id,
                hierarchyId,
                ord.AccountId,
                groupAccountId,
                cityId,
                stateId,
                countryId
                    );
                
                if(score >= 0 && score > bestScore){
                    bestScore = score;
                    bestMargin = m;
                }
            }
            
            if(bestMargin == null){
                item.addError('No margin found.');
                continue;
            }
            
            item.Margin_Percentage__c = bestMargin.Value__c;
        }
    }
}