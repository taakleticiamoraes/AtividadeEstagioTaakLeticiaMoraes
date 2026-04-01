public class OrderItemService {

    public static void validateItems(List<OrderItem> items, Map<Id, Order> orderMap){

        for(OrderItem item : items){

            if(item.Quantity == null || item.Quantity <= 0){
                item.addError('Quantity must be greater than zero.');
            }

            if(item.Selling_Price__c == null || item.Selling_Price__c <= 0){
                item.addError('Selling price must be greater than zero.');
            }

            Order ord = orderMap.get(item.OrderId);

            if(ord != null && ord.Status == 'Activated'){
                item.addError('Não é possível alterar itens de um pedido ativo.');
            }
        }
    }
}