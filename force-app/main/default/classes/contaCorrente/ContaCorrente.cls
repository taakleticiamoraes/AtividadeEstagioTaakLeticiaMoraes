public with sharing class ContaCorrente extends Conta implements Tributavel{
    public ContaCorrente(String numero, String titular) {
        super(numero, titular);
    }

    public override Decimal calcularTaxa(){
        return getSaldo() * 0.01;
    }

    public Decimal calcularImposto() {
        return getSaldo() * 0.02;
    }
}