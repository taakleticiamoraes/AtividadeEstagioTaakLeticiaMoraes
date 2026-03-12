public with sharing class CalculadoraDeTaxas {
    public static Decimal CalculadoraDeTaxas(List<Conta> contas) {
        Decimal totalTaxas = 0;
        for (Conta conta : contas) {
            totalTaxas += conta.calcularTaxa();
        }
        return totalTaxas;

    }
}