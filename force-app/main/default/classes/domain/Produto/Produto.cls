public class Produto extends EntidadeBase {
    
    private String nome;
    private Dinheiro precoBase;
    private PoliticaDePreco politicaDePreco;
    
    public String getNome() {
        return nome;
    }
    
    public Dinheiro getPrecoBase() {
        return precoBase;
    }
    
    public Produto(String pNome, Dinheiro pPreco, PoliticaDePreco pPolitica) {
        super();
        this.nome = pNome;
        this.precoBase = pPreco;
        this.politicaDePreco = pPolitica;
    }
    
    public override String toString() {
        return 'Produto: ' + nome +
            ' - R$' + precoBase.toString();
    }
    
    public Dinheiro calcularPrecoFinal() {
        return politicaDePreco.calcularPreco(this);
    }
    
    public void alterarPoliticaDePreco(PoliticaDePreco novaPolitica) {
        this.politicaDePreco = novaPolitica;
    }
}