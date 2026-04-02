public class OrderService {
    
    public static void validateBeforeInsert(List<Order> newList){
        
        for(Order ord : newList){
            
            if(ord.AccountId == null){
                ord.addError('Account is required.');
            }
            
            if(ord.Address__c == null){
                ord.addError('Delivery address is required.');
            }
            
            if(ord.Distribution_Center__c == null){
                ord.addError('Distribution Center is required.');
            }
        }
    }
    
    public static void validateBeforeUpdate(List<Order> newList, Map<Id, Order> oldMap){
        
        for(Order ord : newList){
            
            Order old = oldMap.get(ord.Id);
            
            if(ord.AccountId != old.AccountId){
                ord.addError('Account cannot be changed after order creation.');
            }
            
            if(old.Status == 'Activated'){
                ord.addError('Cannot update an activated order.');
            }
            
            if(old.Status != 'Activated' && ord.Status == 'Activated'){
                validateActivation(ord);
            }
        }
    }
    
    public static void handleAfterUpdate(List<Order> newList, Map<Id, Order> oldMap){
        
        Set<Id> ordersToRecalculate = new Set<Id>();
        
        for(Order ord : newList){
            
            Order old = oldMap.get(ord.Id);
            
            if(
                ord.Address__c != old.Address__c ||
                ord.Distribution_Center__c != old.Distribution_Center__c ||
                ord.Status != old.Status
            ){
                ordersToRecalculate.add(ord.Id);
            }
        }
        
        if(!ordersToRecalculate.isEmpty()){
            recalculateOrderItems(ordersToRecalculate);
        }
    }
    
    public static void recalculateOrderItems(Set<Id> orderIds){
        
        if(TriggerControl.isRecalculating) return;
        
        TriggerControl.isRecalculating = true;
        
        List<OrderItem> items = [
            SELECT Id,
                OrderId,
                Product2Id,
                Production_Cost__c,
                Shipping_Cost__c,
                Tax_Percentage__c,
                Margin_Percentage__c,
                Selling_Price__c
            FROM OrderItem
            WHERE OrderId IN :orderIds
        ];
        
        if(items.isEmpty()){
            TriggerControl.isRecalculating = false;
            return;
        }
        
        TaxService.applyTax(items);
        FreightService.applyFreight(items);
        MarginService.applyMargin(items);
        
        PricingService.calculatePricing(items);
        
        update items;
        
        TriggerControl.isRecalculating = false;
    }
    
    private static void validateActivation(Order ord){
        
        if(ord.Address__c == null){
            ord.addError('Cannot activate order without address.');
        }
        
        if(ord.Distribution_Center__c == null){
            ord.addError('Cannot activate order without distribution center.');
        }
        
        List<OrderItem> items = [
        SELECT Id, Quantity, Selling_Price__c
        FROM OrderItem
        WHERE OrderId = :ord.Id
    ];
        
        if(items.isEmpty()){
            ord.addError('Cannot activate order without items.');
        }
        
        for(OrderItem item : items){
            if(item.Quantity <= 0){
                ord.addError('All items must have quantity greater than zero.');
            }
            
            if(item.Selling_Price__c <= 0){
                ord.addError('All items must have a valid selling price.');
            }
        }
    }
}