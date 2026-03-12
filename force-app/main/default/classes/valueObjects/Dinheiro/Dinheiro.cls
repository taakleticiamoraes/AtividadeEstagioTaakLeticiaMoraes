public class Dinheiro {
    
    public final Decimal valor;
    
    public Dinheiro(Decimal pValor) {
        if (pValor == null || pValor < 0) {
            System.debug('ERRO: Valor monetário inválido.');
            pValor = 0;
        }
        
        this.valor = pValor.setScale(2);
    }
    
    public Dinheiro somar(Dinheiro pOutro){
        if (pOutro == null) {
            System.debug('ERRO: Valor nulo para soma.');
            return this;
        }
        return new Dinheiro(this.valor + pOutro.valor);
    }
    
    public Dinheiro subtrair(Dinheiro pOutro){
        if (pOutro == null) {
            System.debug('ERRO: Valor nulo para subtração.');
            return this;
        }
        Decimal resultado = this.valor - pOutro.valor;
        
        if (resultado < 0) {
            System.debug('ERRO: Resultado não pode ser negativo.');
            return this;
        }
        
        return new Dinheiro(resultado);
    }
    
    public Dinheiro multiplicar(Decimal pMultiplicador){
        if (pMultiplicador == null || pMultiplicador < 0) {
            System.debug('ERRO: Multiplicador inválido.');
            return this;
        }
        
        return new Dinheiro(this.valor * pMultiplicador);
    }
    
    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof Dinheiro)) {
            return false;
        }
        
        Dinheiro outro = (Dinheiro) obj;
        return this.valor == outro.valor;
    }
    
    public override Integer hashCode() {
        return valor.hashCode();
    }
    
    public override String toString() {
        return 'R$ ' + valor.setScale(2);
    }
    
    public static Dinheiro zero(){
        return new Dinheiro(0);
    }
}