public class MarginService {
    public static void validateCategories(List<Margin__c> records){
        
        for(Margin__c margin : records){
            
            CategoryValidation.validateProductCategory(
                margin,
            margin.Product__c,
            margin.Product_Hierarchy__c
                );
            
            if(margin.Account__c == null && margin.Group_Account__c == null){
                margin.addError('Fill Account OR Group Account.');
            }
            
            if(margin.Account__c != null && margin.Group_Account__c != null){
                margin.addError('Cannot fill both Account and Group Account.');
            }
            
            Integer filled = 0;
            
            if(margin.City__c != null) filled++;
            if(margin.State__c != null) filled++;
            if(margin.Country__c != null) filled++;
            
            if(filled == 0){
                margin.addError('Fill City OR State OR Country.');
            }
            
            if(filled > 1){
                margin.addError('Only one location field can be filled.');
            }
        }
    }
    
    public static void validateDuplicates(List<Margin__c> records){
        
        Set<String> keys = new Set<String>();
        
        for(Margin__c margin : [
        SELECT Product__c, Product_Hierarchy__c,
               Account__c, Group_Account__c,
               City__c, State__c, Country__c
        FROM Margin__c
    ]){
            keys.add(buildKey(margin));
        }
        
        for(Margin__c margin : records){
            
            if(margin.Product__c != null && margin.Product_Hierarchy__c != null){
                margin.addError('Cannot fill both Product and Hierarchy.');
            }
            
            if(margin.Account__c != null && margin.Group_Account__c != null){
                margin.addError('Cannot fill both Account and Group.');
            }
            
            String key = buildKey(margin);
            
            if(keys.contains(key)){
                margin.addError('Duplicate margin configuration.');
            }
            
            keys.add(key);
        }
    }
    
    private static String buildKey(Margin__c margin){
        return String.valueOf(margin.Product__c) + '-' +
            String.valueOf(margin.Product_Hierarchy__c) + '-' +
            String.valueOf(margin.Account__c) + '-' +
            String.valueOf(margin.Group_Account__c) + '-' +
            String.valueOf(margin.City__c) + '-' +
            String.valueOf(margin.State__c) + '-' +
            String.valueOf(margin.Country__c);
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
        
        for(Order order : orders.values()){
            if(order.AccountId != null){
                accountIds.add(order.AccountId);
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
            
            Order order = orders.get(item.OrderId);
            if(order == null){
                item.addError('Order not found.');
                continue;
            }
            
            if(order.Address__c == null || order.Address__r == null){
                item.addError('Order without address.');
                continue;
            }
            
            Product2 prod = products.get(item.Product2Id);
            Account acc = accounts.get(order.AccountId);
            
            Id hierarchyId = (prod != null) ? prod.Product_Hierarchy__c : null;
            Id groupAccountId = (acc != null) ? acc.Group_Account__c : null;
            
            Id cityId = order.Address__r.City__c;
            Id stateId = order.Address__r.City__r.State__c;
            Id countryId = order.Address__r.City__r.State__r.Country__c;
            
            Integer bestScore = -1;
            Margin__c bestMargin;
            
            for(Margin__c margin : margins){
                
                Integer score = ScoringService.calculateMarginScore(
                    margin,
                    item.Product2Id,
                    hierarchyId,
                    order.AccountId,
                    groupAccountId,
                    cityId,
                    stateId,
                    countryId
                );
                
                if(score >= 0 && score > bestScore){
                    bestScore = score;
                    bestMargin = margin;
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