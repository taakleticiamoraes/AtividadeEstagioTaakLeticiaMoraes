public class EstadoEmProcessamento extends EstadoPedido {
    
    public override void adicionarProduto(Pedido pedido, Produto produto, Integer quantidade) {
        System.debug('ERRO: Pedido em processamento não pode ser alterado.');
        return;
    }
    
    public override void removerProduto(Pedido pedido, Produto produto) {
        System.debug('ERRO: Pedido em processamento não pode ser alterado.');
        return;
    }
    
    public override void confirmar(Pedido pedido) {
        System.debug('ERRO: Pedido já foi confirmado.');
        return;
    }
    
    public override void cancelar(Pedido pedido) {
        pedido.alterarEstado(new EstadoCancelado());
    }
    
    public override void marcarComoEntregue(Pedido pedido) {
        pedido.alterarEstado(new EstadoEntregue());
    }
    
    public override String nome(){
        return 'EM_PROCESSAMENTO';
    }
}