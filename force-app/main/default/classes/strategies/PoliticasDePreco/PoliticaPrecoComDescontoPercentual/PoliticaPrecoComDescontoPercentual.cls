public class PoliticaPrecoComDescontoPercentual implements PoliticaDePreco {
    
    private Decimal percentual;
    
    public PoliticaPrecoComDescontoPercentual(Decimal pPercentual) {
        
        if (pPercentual > 100 || pPercentual < 0) {
            System.debug('Percentual de desconto inválido. Valor recebido: ' + pPercentual);
            this.percentual = 0;
            return;
        }
        
        this.percentual = pPercentual;
    }
    
    public Dinheiro calcularPreco(Produto pProduto) {
        
        Dinheiro precoBase = pProduto.getPrecoBase();
        Decimal fator = (100 - percentual) / 100;
        
        return precoBase.multiplicar(fator);
    }
}