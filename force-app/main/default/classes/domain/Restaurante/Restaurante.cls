public class Restaurante extends EntidadeBase {
    
    private String nome;
    private Endereco endereco;
    private CategoriaRestaurante categoria;
    private List<Produto> cardapio;
    
    public String getNome() { return nome; }
    public Endereco getEndereco() { return endereco; }
    public CategoriaRestaurante getCategoria() { return categoria; }
    public List<Produto> getCardapio() {
        return cardapio.clone();
    }
    
    public Restaurante(String pNome, Endereco pEndereco, CategoriaRestaurante pCategoria) {
        super();
        
        if (String.isBlank(pNome)) {
            System.debug('ERRO: Nome do restaurante inválido.');
        }
        
        if (pEndereco == null) {
            System.debug('ERRO: Endereço obrigatório.');
        }
        
        this.nome = pNome;
        this.endereco = pEndereco;
        this.categoria = pCategoria;
        this.cardapio = new List<Produto>();
    }
    
    public void adicionarProduto(Produto pProduto) {
        if (pProduto == null) {
            System.debug('Erro: Produto inválido.');
            return;
        }
        
        for (Produto produtoExistente : cardapio) {
            if (produtoExistente.getNome().equalsIgnoreCase(pProduto.getNome())) {
                System.debug('Produto já existe no cardápio.');
                return;
            }
        }
        
        cardapio.add(pProduto);
        System.debug('Produto adicionado ao cardápio.');
    }
}