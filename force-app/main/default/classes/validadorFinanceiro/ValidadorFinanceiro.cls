public with sharing class ValidadorFinanceiro {
    public static void validarValor(Decimal valor) {

        if (valor == null || valor <= 0) {
            throw new IllegalArgumentException('Valor deve ser maior que zero.');
        }
    }
}