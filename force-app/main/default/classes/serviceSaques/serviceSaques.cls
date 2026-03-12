public with sharing class serviceSaques {
    public static void tentarScar(Conta conta, Decimal valor) {
        try{
            conta.sacar(valor);
        }catch(SaldoInsuficienteException e){
            System.debug('Erro ao Sacar: ' + e.getMessage());
        }
    }
}