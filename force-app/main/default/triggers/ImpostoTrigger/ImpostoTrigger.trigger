trigger ImpostoTrigger on Imposto__c (before insert, before update) {

    Set<String> keys = new Set<String>();

    for(Imposto__c imp : Trigger.new){

        String key =
            imp.Produto__c + '-' +
            imp.Centro_de_Distribuicao__c + '-' +
            imp.Estado__c;

        if(keys.contains(key)){
            imp.addError('Já existe um imposto com essa combinação.');
        }

        keys.add(key);
    }
}