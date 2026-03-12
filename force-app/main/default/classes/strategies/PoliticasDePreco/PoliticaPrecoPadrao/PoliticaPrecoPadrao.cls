public class PoliticaPrecoPadrao implements PoliticaDePreco {
    
    public Dinheiro calcularPreco(Produto pProduto) {
        return pProduto.getPrecoBase();
    }
}