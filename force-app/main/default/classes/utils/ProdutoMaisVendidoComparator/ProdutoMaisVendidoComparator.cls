public class ProdutoMaisVendidoComparator implements Comparator<Produto> {
    
    private Map<Produto, Integer> vendas;
    
    public ProdutoMaisVendidoComparator(Map<Produto, Integer> pVendas) {
        this.vendas = pVendas;
    }
    
    public Integer compare(Produto pA, Produto pB) {
        Integer qtdA = vendas.containsKey(pA) ? vendas.get(pA) : 0;
        Integer qtdB = vendas.containsKey(pB) ? vendas.get(pB) : 0;
        
        if (qtdA != qtdB) {
            return qtdB - qtdA;
        }
        
        return pA.getNome().toLowerCase().compareTo(
            pB.getNome().toLowerCase()
            );
    }
}