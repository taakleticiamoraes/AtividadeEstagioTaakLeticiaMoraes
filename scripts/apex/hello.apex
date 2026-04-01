System.debug('===== CLEAN START =====');

// função "manual"
List<SObject> records;

// ORDER ITEM
records = [SELECT Id FROM OrderItem];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// ORDER
records = [SELECT Id FROM Order];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// MARGIN
records = [SELECT Id FROM Margin__c];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// TAX
records = [SELECT Id FROM Tax__c];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// FREIGHT
records = [SELECT Id FROM Freight__c];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// PRICEBOOK ENTRY
records = [SELECT Id FROM PricebookEntry WHERE Pricebook2.IsStandard = false];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// PRODUCT
records = [SELECT Id FROM Product2];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// ADDRESS
records = [SELECT Id FROM Address__c];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// ACCOUNT
records = [SELECT Id FROM Account WHERE Name LIKE 'Cliente Teste%'];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// GROUP ACCOUNT
records = [SELECT Id FROM Group_Account__c];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// DISTRIBUTION CENTER
records = [SELECT Id FROM Distribution_Center__c];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// PAYMENT TERMS
records = [SELECT Id FROM Payment_Terms__c];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// CITY
records = [SELECT Id FROM City__c];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// STATE
records = [SELECT Id FROM State__c];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

// COUNTRY
records = [SELECT Id FROM Country__c];
if(!records.isEmpty()){
    try { delete records; } catch(Exception e){ System.debug(e.getMessage()); }
}

System.debug('===== CLEAN END =====');

System.debug('===== START TEST =====');

// SUFIXO ÚNICO
String suffix = String.valueOf(DateTime.now());

// 1. COUNTRY
Country__c country = new Country__c(Acronym__c = 'BR');
insert country;

// 2. STATE
State__c state = new State__c(
    Country__c = country.Id,
    Acronym__c = 'SP'
);
insert state;

// 3. CITY
City__c city = new City__c(
    State__c = state.Id,
    IBGE_Code__c = '3550308'
);
insert city;

// 4. GROUP ACCOUNT
Group_Account__c groupAcc = new Group_Account__c();
insert groupAcc;

// 5. ACCOUNT
Account acc = new Account(
    Name = 'Cliente Teste ' + suffix,
    CNPJ__c = '12345678000199',
    Group_Account__c = groupAcc.Id
);
insert acc;

// 6. ADDRESS
Address__c addr = new Address__c(
    Account__c = acc.Id,
    City__c = city.Id,
    Street__c = 'Rua Teste',
    CEP__c = '00000000',
    Neighborhood__c = 'Centro'
);
insert addr;

// 7. PAYMENT TERMS
Payment_Terms__c pt = new Payment_Terms__c();
insert pt;

// 8. DISTRIBUTION CENTER
Distribution_Center__c dc = new Distribution_Center__c();
insert dc;

// 9. PRODUCT HIERARCHY
Product_Hierarchy__c hierarchy = new Product_Hierarchy__c();
insert hierarchy;

// 10. PRODUCT
Product2 prod = new Product2(
    Name = 'Produto Teste ' + suffix,
    IsActive = true,
    Product_Hierarchy__c = hierarchy.Id
);
insert prod;

// 11. STANDARD PRICEBOOK
Pricebook2 stdPb = [SELECT Id, IsActive FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

if(!stdPb.IsActive){
    stdPb.IsActive = true;
    update stdPb;
}

// 12. PRICEBOOK ENTRY
PricebookEntry pbe = new PricebookEntry(
    Pricebook2Id = stdPb.Id,
    Product2Id = prod.Id,
    UnitPrice = 100,
    IsActive = true
);
insert pbe;

// 13. ORDER
Order ord = new Order(
    Name = 'Pedido Teste ' + suffix,
    AccountId = acc.Id,
    EffectiveDate = Date.today(),
    Status = 'Draft',
    Distribution_Center__c = dc.Id,
    Payment_Terms__c = pt.Id,
    Type_of_shipping__c = 'CIF',
    Address__c = addr.Id,
    Delivery_Date__c = Date.today().addDays(5),
    Pricebook2Id = stdPb.Id
);
insert ord;

// 14. TAX
Tax__c tax = new Tax__c(
    Product__c = prod.Id,
    Distribution_Center__c = dc.Id,
    State__c = state.Id,
    Status__c = 'Approved',
    Tax_on_cost__c = 15
);
insert tax;

// 15. FREIGHT
Freight__c freight = new Freight__c(
    Product__c = prod.Id,
    Distribution_Center__c = dc.Id,
    City__c = city.Id,
    Country__c = country.Id,
    Status__c = 'Approved',
    Value__c = 25
);
insert freight;

// 16. MARGIN
Margin__c margin = new Margin__c(
    Account__c = acc.Id,
    Product__c = prod.Id,
    Distribution_Center__c = dc.Id,
    State__c = state.Id,
    Status__c = 'Approved',
    Value__c = 20
);
insert margin;

// 17. ORDER ITEM
OrderItem item = new OrderItem(
    OrderId = ord.Id,
    PricebookEntryId = pbe.Id,
    Quantity = 1,
    UnitPrice = 100,
    Selling_Price__c = 90,
    Production_Cost__c = 50
);
insert item;

// 18. VALIDAR RESULTADO
item = [
    SELECT Id,
           Tax_Percentage__c,
           Shipping_Cost__c,
           Margin_Percentage__c,
           Price_without_margin__c,
           Final_Price__c,
           Discount__c
    FROM OrderItem
    WHERE Id = :item.Id
];

System.debug('===== RESULT =====');
System.debug(JSON.serializePretty(item));

if(item.Tax_Percentage__c == null ||
   item.Shipping_Cost__c == null ||
   item.Margin_Percentage__c == null){

    System.debug('ERRO: Parâmetros não aplicados corretamente');
}else{
    System.debug('Pricing aplicado com sucesso');
}

System.debug('===== END TEST =====');