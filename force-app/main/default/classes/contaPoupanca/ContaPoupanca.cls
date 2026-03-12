public with sharing class ContaPoupanca extends Conta{
    public ContaPoupanca(String numero, String titular) {
        super(numero, titular);
    }
    
    public override Decimal calcularTaxa() {
        return getSaldo() * 0.05;
    }
}