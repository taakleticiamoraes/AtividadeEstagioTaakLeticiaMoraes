public class TaxService {

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

            if(ord == null || ord.Address__r == null || ord.Address__r.City__r == null){
                item.addError('Order without valid address.');
                continue;
            }

            Id productId = item.Product2Id;
            Id dcId = ord.Distribution_Center__c;
            Id stateId = ord.Address__r.City__r.State__c; // 🔥 AGORA CERTO

            Tax__c bestMatch;

            for(Tax__c tax : taxes){

                if(tax.Product__c == productId &&
                   tax.Distribution_Center__c == dcId &&
                   tax.State__c == stateId){

                    bestMatch = tax;
                    break;
                }

                if(bestMatch == null &&
                   tax.Product__c == productId &&
                   tax.Distribution_Center__c == dcId){

                    bestMatch = tax;
                }

                if(bestMatch == null &&
                   tax.Product__c == productId){

                    bestMatch = tax;
                }
            }

            if(bestMatch == null){
                item.addError('No tax configuration found.');
                continue;
            }

            item.Tax_Percentage__c = bestMatch.Tax_on_cost__c;
        }
    }
}