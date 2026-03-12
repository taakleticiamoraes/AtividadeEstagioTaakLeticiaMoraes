public with sharing class CalculadoraDeImpostos {
    public static Decimal calcularTotalImpostos(List<Tributavel> tributaveis) {
        Decimal total = 0;
        
        for(Tributavel i : tributaveis){
            total += i.calcularImposto();
        }

        return total;
    }
}