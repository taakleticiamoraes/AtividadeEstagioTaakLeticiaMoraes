public with sharing class ServiceConta {
    public static List<Conta> buscarContasExistentes(
        Set<Integer> numeros,
        Map<Integer, Conta> contasMap
    ){
        List<Conta> encontradas = new List<Conta>();

        for(Integer numero : numeros){
            if(contasMap.containsKey(numero)){
                encontradas.add(contasMap.get(numero));
            }
        }

        return encontradas;

    }
}