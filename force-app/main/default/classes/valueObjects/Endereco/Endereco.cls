public class Endereco {
    
    public final String logradouro;
    public final String numero;
    public final String complemento;
    public final String cidade;
    
    public Endereco(
        String pLogradouro,
    String pNumero,
    String pComplemento,
    String pCidade
    ) {
        if (String.isBlank(pLogradouro) || String.isBlank(pNumero) || String.isBlank(pCidade)) {
            System.debug('ERRO: Endereço inválido.');
        }
        
        this.logradouro = pLogradouro;
        this.numero = pNumero;
        this.complemento = pComplemento;
        this.cidade = pCidade;
    }
    
    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof Endereco)) {
            return false;
        }
        
        Endereco outro = (Endereco) obj;
        
        return logradouro == outro.logradouro &&
            numero == outro.numero &&
            complemento == outro.complemento &&
            cidade == outro.cidade;
    }
    
    public override Integer hashCode() {
        return (logradouro + numero + complemento + cidade).hashCode();
    }
    
    public override String toString() {
        return logradouro + ', ' + numero +
            (complemento != null ? ' - ' + complemento : '') +
            ' - ' + cidade;
    }
}