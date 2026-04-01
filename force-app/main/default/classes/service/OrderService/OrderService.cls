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
                ord.addError('Não é possível atualizar a conta do pedido');
            }

            if(old.Status == 'Activated'){
                ord.addError('Não é possível alterar um pedido ativo.');
            }
        }
    }
}