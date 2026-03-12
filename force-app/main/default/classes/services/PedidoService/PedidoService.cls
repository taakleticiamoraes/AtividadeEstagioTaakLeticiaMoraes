public class PedidoService {

    private PoliticaDeFrete politicaDeFrete;

    public PedidoService(PoliticaDeFrete pPoliticaDeFrete) {
        this.politicaDeFrete = pPoliticaDeFrete;
    }

    public void confirmarPedido(Pedido pedido) {

        if (!validarConfirmacao(pedido)) {
            return;
        }

        aplicarFrete(pedido);

        pedido.confirmar();
    }

    public void cancelarPedido(Pedido pedido) {

        String statusAtual = pedido.getEstado();

        if (statusAtual == 'ENTREGUE') {
            System.debug('ERRO: Pedido entregue não pode ser cancelado.');
            return;
        }

        if (statusAtual == 'CANCELADO') {
            System.debug('ERRO: Pedido já cancelado.');
            return;
        }

        pedido.cancelar();
    }

    public void marcarComoEntregue(Pedido pedido) {

        if (pedido.getEstado() != 'EM_PROCESSAMENTO') {
            System.debug('ERRO: Apenas pedidos em processamento podem ser entregues.');
            return;
        }

        pedido.marcarComoEntregue();
    }

    private Boolean validarConfirmacao(Pedido pedido) {

        if (pedido == null) {
            System.debug('ERRO: Pedido inválido.');
            return false;
        }

        if (pedido.getEstado() != 'CARRINHO') {
            System.debug('ERRO: Pedido não está no estado correto.');
            return false;
        }

        if (pedido.estaVazio()) {
            System.debug('ERRO: Pedido não pode estar vazio.');
            return false;
        }

        if (pedido.getTotal().valor <= 0) {
            System.debug('ERRO: Total do pedido inválido.');
            return false;
        }

        if (pedido.getRestaurante() == null) {
            System.debug('ERRO: Pedido sem restaurante.');
            return false;
        }

        if (pedido.getCliente() == null) {
            System.debug('ERRO: Pedido sem cliente.');
            return false;
        }

        return true;
    }

    private void aplicarFrete(Pedido pedido) {

        if (politicaDeFrete == null) {
            return;
        }

        Dinheiro frete = politicaDeFrete.calcularFrete(pedido);

        if (frete == null) {
            return;
        }

        pedido.aplicarFrete(frete);

        System.debug('Frete aplicado: ' + frete);
    }
}