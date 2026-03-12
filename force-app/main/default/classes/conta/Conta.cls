public with sharing abstract class Conta {
    
    private String numero;
    private String titular;
    private Decimal saldo;
    public static Integer totalContas = 0;
    
    
    public Conta(String numero, String titular) {
        this.numero = numero;
        this.titular = titular;
        this.saldo = 0;
        totalContas++;
    }
    
    public void depositar(Decimal valor) {
        ValidadorFinanceiro.validarValor(valor);
        this.saldo += valor;
        
    }
    
    public void sacar(Decimal valor) {
        ValidadorFinanceiro.validarValor(valor);
        if (valor > saldo) {
            throw new SaldoInsuficienteException('Saldo insuficiente para saque.');
        }
        this.saldo -= valor;
    }
    
    public Decimal getSaldo() {
        return saldo;
    }
    
    public abstract Decimal calcularTaxa();
}