public class FreteFixo implements PoliticaDeFrete {
    
    private Dinheiro valor;
    
    public FreteFixo(Dinheiro pValor) {
        this.valor = pValor;
    }
    
    public Dinheiro calcularFrete(Pedido pedido) {
        return valor;
    }
    
}