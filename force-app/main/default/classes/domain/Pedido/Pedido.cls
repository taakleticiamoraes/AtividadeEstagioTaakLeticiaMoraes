public class Pedido extends EntidadeBase {
    
    private Cliente cliente;
    private Restaurante restaurante;
    private List<ItemPedido> itens;
    private EstadoPedido estadoAtual;
    private Dinheiro total;
    
    public Cliente getCliente() { return cliente; }
    public Restaurante getRestaurante() { return restaurante; }
    public Dinheiro getTotal() { return total; }
    public String getEstado() {
        return estadoAtual.nome();
    }
    
    public List<ItemPedido> getItens() {
        return itens.clone();
    }
    
    public Pedido(Cliente pCliente, Restaurante pRestaurante) {
        super();
        
        this.cliente = pCliente;
        this.restaurante = pRestaurante;
        this.estadoAtual = new EstadoCarrinho();
        this.itens = new List<ItemPedido>();
        this.total = new Dinheiro(0);
    }
    
    public Boolean estaVazio() {
        return itens.isEmpty();
    }
    
    public void adicionarProduto(Produto pProduto, Integer pQuantidade) {
        estadoAtual.adicionarProduto(this, pProduto, pQuantidade);
    }
    
    public void confirmar() {
        estadoAtual.confirmar(this);
    }
    
    public void cancelar() {
        estadoAtual.cancelar(this);
    }
    
    public void marcarComoEntregue() {
        estadoAtual.marcarComoEntregue(this);
    }
    
    public void alterarEstado(EstadoPedido novoEstado) {
        this.estadoAtual = novoEstado;
    }
    
    public void adicionarItemInterno(Produto pProduto, Integer pQuantidade) {
        for (ItemPedido item : itens) {
            if (item.getProduto().equals(pProduto)) {
                
                Integer novaQuantidade = item.getQuantidade() + pQuantidade;
                item.atualizarQuantidade(novaQuantidade);
                
                recalcularTotal();
                return;
            }
        }
        
        ItemPedido novoItem = new ItemPedido(pProduto, pQuantidade);
        itens.add(novoItem);
        
        recalcularTotal();
    }
    
    private void recalcularTotal() {
        
        Dinheiro soma = new Dinheiro(0);
        
        for (ItemPedido item : itens) {
            soma = soma.somar(item.getSubtotal());
        }
        
        total = soma;
    }
    public void removerItemInterno(Produto produto){
        
        for(Integer i = 0; i < itens.size(); i++){
            
            if(itens[i].getProduto().equals(produto)){
                itens.remove(i);
                recalcularTotal();
                return;
            }
            
        }
        
    }
    public void aplicarFrete(Dinheiro frete) {
        
        if (frete == null) {
            return;
        }
        
        this.total = this.total.somar(frete);
    }
}