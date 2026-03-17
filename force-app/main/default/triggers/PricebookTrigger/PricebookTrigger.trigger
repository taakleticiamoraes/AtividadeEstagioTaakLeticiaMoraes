trigger PricebookTrigger on Product2 (after insert) {

    // pegar pricebook padrão
    Pricebook2 standardPb = [
        SELECT Id
        FROM Pricebook2
        WHERE IsStandard = true
        LIMIT 1
    ];

    // pegar moedas ativas
    List<CurrencyType> moedas = [
        SELECT IsoCode
        FROM CurrencyType
        WHERE IsActive = true
    ];

    List<PricebookEntry> entries = new List<PricebookEntry>();

    // loop produtos criados
    for(Product2 produto : Trigger.new){

        // loop moedas
        for(CurrencyType moeda : moedas){

            PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = standardPb.Id;
            pbe.Product2Id = produto.Id;
            pbe.UnitPrice = 0;
            pbe.IsActive = true;
            pbe.CurrencyIsoCode = moeda.IsoCode;

            entries.add(pbe);
        }

    }

    if(!entries.isEmpty()){
        insert entries;
    }

}