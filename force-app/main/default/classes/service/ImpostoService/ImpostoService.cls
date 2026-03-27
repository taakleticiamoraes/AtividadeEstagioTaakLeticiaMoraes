public class ImpostoService {

    public static void applyImposto(List<Produto_do_Pedido__c> items){

        Set<Id> pedidoIds = new Set<Id>();

        for(Produto_do_Pedido__c item : items){
            if(item.Pedido__c != null){
                pedidoIds.add(item.Pedido__c);
            }
        }

        Map<Id, Pedido__c> pedidos = new Map<Id, Pedido__c>([
            SELECT Id,
                   Centro_de_Distribuicao__c,
                   Endereco_da_Conta__r.Cidade__r.Estado__c
            FROM Pedido__c
            WHERE Id IN :pedidoIds
        ]);

        List<Imposto__c> impostos = [
            SELECT Id,
                   Produto__c,
                   Centro_de_Distribuicao__c,
                   Estado__c,
                   Imposto_sobre_custo__c
            FROM Imposto__c
            WHERE Status__c = 'Aprovado'
        ];

        for(Produto_do_Pedido__c item : items){

            Pedido__c ped = pedidos.get(item.Pedido__c);

            if(ped == null || ped.Endereco_da_Conta__r == null || ped.Endereco_da_Conta__r.Cidade__r == null){
                item.addError('Pedido sem endereço válido.');
                continue;
            }

            Id produtoId = item.Produto__c;
            Id cdId = ped.Centro_de_Distribuicao__c;
            String estado = ped.Endereco_da_Conta__r.Cidade__r.Estado__c;

            Imposto__c melhor;

            for(Imposto__c imp : impostos){

                if(imp.Produto__c == produtoId &&
                   imp.Centro_de_Distribuicao__c == cdId &&
                   imp.Estado__c == estado){

                    melhor = imp;
                    break;
                }

                if(melhor == null &&
                   imp.Produto__c == produtoId &&
                   imp.Centro_de_Distribuicao__c == cdId){

                    melhor = imp;
                }

                if(melhor == null &&
                   imp.Produto__c == produtoId){

                    melhor = imp;
                }
            }

            if(melhor == null){
                item.addError('Não existe imposto configurado.');
                continue;
            }

            item.Porcentagem_de_Imposto__c = melhor.Imposto_sobre_custo__c;
        }
    }
}