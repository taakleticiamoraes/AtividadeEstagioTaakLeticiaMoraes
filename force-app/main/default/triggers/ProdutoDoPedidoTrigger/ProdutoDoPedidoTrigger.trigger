trigger ProdutoDoPedidoTrigger on Produto_do_Pedido__c (before insert, before update) {
    ImpostoService.applyImposto(Trigger.new);
}