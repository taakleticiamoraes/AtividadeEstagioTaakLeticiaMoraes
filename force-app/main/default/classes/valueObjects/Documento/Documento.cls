public class Documento {
    
    public final String valor;
    
    public Documento(String pValor) {
        if (String.isBlank(pValor)) {
            System.debug('ERRO: Documento inválido.');
            pValor = '00000000000';
        }
        
        this.valor = pValor;
    }
    
    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof Documento)) {
            return false;
        }
        
        Documento outro = (Documento) obj;
        return this.valor == outro.valor;
    }
    
    public override Integer hashCode() {
        return valor.hashCode();
    }
    
    public override String toString() {
        return valor;
    }
    
    public String getValor() {
        return valor;
    }
}