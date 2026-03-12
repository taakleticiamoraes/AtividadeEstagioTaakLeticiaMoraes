public class EstadoCancelado extends EstadoPedido {
    
    public override void adicionarProduto(Pedido pedido, Produto produto, Integer quantidade) {
        System.debug('ERRO: Pedido cancelado não pode ser modificado.');
        return;
    }
    
    public override void removerProduto(Pedido pedido, Produto produto) {
        System.debug('ERRO: Pedido cancelado não pode ser modificado.');
        return;
    }
    
    public override void confirmar(Pedido pedido) {
        System.debug('ERRO: Pedido cancelado não pode ser confirmado.');
        return;
    }
    
    public override void cancelar(Pedido pedido) {
        System.debug('ERRO: Pedido já está cancelado.');
        return;
    }
    
    public override void marcarComoEntregue(Pedido pedido) {
        System.debug('ERRO: Pedido cancelado não pode ser entregue.');
        return;
    }
    
    public override String nome(){
        return 'CANCELADO';
    }
}