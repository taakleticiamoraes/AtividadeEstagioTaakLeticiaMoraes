public class FretePercentual implements PoliticaDeFrete {
    
    private Decimal percentual;
    
    public FretePercentual(Decimal pPercentual) {
        this.percentual = pPercentual;
    }
    
    public Dinheiro calcularFrete(Pedido pedido) {
        
        return pedido.getTotal().multiplicar(percentual);
        
    }
    
}