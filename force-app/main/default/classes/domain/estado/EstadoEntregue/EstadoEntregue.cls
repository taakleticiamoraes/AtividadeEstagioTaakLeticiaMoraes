public class EstadoEntregue extends EstadoPedido {
    
    public override void adicionarProduto(Pedido pedido, Produto produto, Integer quantidade) {
        System.debug('ERRO: Pedido entregue não pode ser modificado.');
        return;
    }
    
    public override void removerProduto(Pedido pedido, Produto produto) {
        System.debug('ERRO: Pedido entregue não pode ser modificado.');
        return;
    }
    
    public override void confirmar(Pedido pedido) {
        System.debug('ERRO: Pedido já entregue.');
        return;
    }
    
    public override void cancelar(Pedido pedido) {
        System.debug('ERRO: Pedido entregue não pode ser cancelado.');
        return;
    }
    
    public override void marcarComoEntregue(Pedido pedido) {
        System.debug('ERRO: Pedido já está entregue.');
        return;
    }
    
    public override String nome(){
        return 'ENTREGUE';
    }
    
}