public abstract class Pessoa extends EntidadeBase {
    public String nome { get; private set; }
    private Documento documento;
    
    public Documento getDocumento() {
        return documento;
    }
    
    public Pessoa(String pNome, Documento pDocumento) {
        super();
        
        if (String.isBlank(pNome)) {
            System.debug('ERRO: Nome não pode ser vazio.');
        }
        
        if (pDocumento == null) {
            System.debug('ERRO: Documento é obrigatório.');
        }
        
        this.nome = pNome;
        this.documento = pDocumento;
    }
    
    public abstract String getTipoPessoa();
}