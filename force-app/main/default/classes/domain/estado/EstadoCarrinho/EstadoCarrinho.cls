public class EstadoCarrinho extends EstadoPedido {
    
    public override void adicionarProduto(Pedido pedido, Produto produto, Integer quantidade) {
        pedido.adicionarItemInterno(produto, quantidade);
    }
    
    public override void removerProduto(Pedido pedido, Produto produto) {
        pedido.removerItemInterno(produto);
    }
    
    public override void confirmar(Pedido pedido) {
        
        if(pedido.getItens().isEmpty()){
            System.debug('ERRO: Pedido não pode ser confirmado sem itens.');
            return;
        }
        
        pedido.alterarEstado(new EstadoEmProcessamento());
    }
    
    public override void cancelar(Pedido pedido) {
        pedido.alterarEstado(new EstadoCancelado());
    }
    
    public override void marcarComoEntregue(Pedido pedido) {
        System.debug('ERRO: Pedido em carrinho não pode ser entregue.');
        return;
    }
    
    public override String nome(){
        return 'CARRINHO';
    }
    
}