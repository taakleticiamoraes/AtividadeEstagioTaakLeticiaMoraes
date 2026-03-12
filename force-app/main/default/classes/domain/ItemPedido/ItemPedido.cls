public class ItemPedido extends EntidadeBase {
    
    private Produto produto;
    private Integer quantidade;
    private Dinheiro subtotal;
    
    public Produto getProduto() { return produto; }
    public Integer getQuantidade() { return quantidade; }
    public Dinheiro getSubtotal() { return subtotal; }
    
    public ItemPedido(Produto pProduto, Integer pQuantidade) {
        super();
        
        this.produto = pProduto;
        this.quantidade = pQuantidade;
        recalcularSubtotal();
    }

    private void recalcularSubtotal() {
        Dinheiro precoFinal = produto.calcularPrecoFinal();
        this.subtotal = precoFinal.multiplicar(quantidade);
    }
    
    public void atualizarQuantidade(Integer novaQuantidade) {
        if (novaQuantidade == null || novaQuantidade <= 0) {
            System.debug('Quantidade inválida.');
            return;
        }

        this.quantidade = novaQuantidade;
        recalcularSubtotal();
    }
}