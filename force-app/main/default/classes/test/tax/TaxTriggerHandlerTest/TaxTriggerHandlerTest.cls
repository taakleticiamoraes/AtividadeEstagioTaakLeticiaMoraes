@IsTest
public class TaxTriggerHandlerTest {
    
    @TestSetup
    static void setup() {
        Id stdPbId = Test.getStandardPricebookId();
        update new Pricebook2(
            Id = stdPbId,
        IsActive = true
            );
        
        Tax__c tax = (Tax__c) TestFactorySObject.getInstance()
            .createSObject(new Tax__c());
        insert tax;
    }
    
    @IsTest
    static void testTrigger_InsertWithValidData() {
        Tax__c base = [SELECT Product__c, Distribution_Center__c, State__c FROM Tax__c LIMIT 1];
        
        // Create a new product to avoid duplicate constraint
        Product2 newProduct = (Product2) TestFactorySObject.getInstance()
            .createSObject(new Product2());
        insert newProduct;
        
        Tax__c tax = new Tax__c(
            Product__c = newProduct.Id,
        Distribution_Center__c = base.Distribution_Center__c,
        State__c = base.State__c,
        Status__c = 'Approved',
        Tax_on_cost__c = 12.0
            );
        
        Test.startTest();
        insert tax;
        Test.stopTest();
        
        System.assertNotEquals(null, tax.Id);
    }
    
    @IsTest
    static void testTrigger_InsertWithTaxPercentage() {
        Tax__c base = [SELECT Product__c, Distribution_Center__c, State__c FROM Tax__c LIMIT 1];
        
        Product2 newProduct = (Product2) TestFactorySObject.getInstance()
            .createSObject(new Product2());
        insert newProduct;
        
        Tax__c tax = new Tax__c(
            Product__c = newProduct.Id,
        Distribution_Center__c = base.Distribution_Center__c,
        State__c = base.State__c,
        Status__c = 'Approved',
        Tax_on_cost__c = 8.5
            );
        
        Test.startTest();
        insert tax;
        Test.stopTest();
        
        Tax__c insertedTax = [SELECT Tax_on_cost__c FROM Tax__c WHERE Id = :tax.Id];
        System.assertEquals(8.5, insertedTax.Tax_on_cost__c);
    }
    
    @IsTest
    static void testTrigger_InsertMultipleTaxes() {
        Tax__c baseTax = [SELECT Product__c, Distribution_Center__c, State__c FROM Tax__c LIMIT 1];
        
        Product2 prod1 = (Product2) TestFactorySObject.getInstance()
            .createSObject(new Product2());
        insert prod1;
        
        Product2 prod2 = (Product2) TestFactorySObject.getInstance()
            .createSObject(new Product2());
        insert prod2;
        
        List<Tax__c> taxesToInsert = new List<Tax__c>{
            new Tax__c(
                Product__c = prod1.Id,
            Distribution_Center__c = baseTax.Distribution_Center__c,
            State__c = baseTax.State__c,
            Status__c = 'Approved',
            Tax_on_cost__c = 10.0
                ),
            new Tax__c(
                Product__c = prod2.Id,
            Distribution_Center__c = baseTax.Distribution_Center__c,
            State__c = baseTax.State__c,
            Status__c = 'Approved',
            Tax_on_cost__c = 15.0
                )
        };
        
        Test.startTest();
        insert taxesToInsert;
        Test.stopTest();
        
        List<Tax__c> insertedTaxes = [SELECT Id FROM Tax__c WHERE Id IN :taxesToInsert];
        System.assertEquals(2, insertedTaxes.size());
    }
    
    @IsTest
    static void testTrigger_UpdateTax() {
        Tax__c baseTax = [SELECT Product__c, Distribution_Center__c, State__c FROM Tax__c LIMIT 1];
        
        Product2 newProduct = (Product2) TestFactorySObject.getInstance()
            .createSObject(new Product2());
        insert newProduct;
        
        Tax__c tax = new Tax__c(
            Product__c = newProduct.Id,
        Distribution_Center__c = baseTax.Distribution_Center__c,
        State__c = baseTax.State__c,
        Status__c = 'Approved',
        Tax_on_cost__c = 10.0
            );
        
        insert tax;
        
        Test.startTest();
        Product2 anotherProduct = (Product2) TestFactorySObject.getInstance()
            .createSObject(new Product2());
        insert anotherProduct;
        
        tax.Product__c = anotherProduct.Id;
        tax.Tax_on_cost__c = 5.0;
        update tax;
        Test.stopTest();
        
        Tax__c updatedTax = [SELECT Tax_on_cost__c, Product__c FROM Tax__c WHERE Id = :tax.Id];
        System.assertEquals(5.0, updatedTax.Tax_on_cost__c);
        System.assertEquals(anotherProduct.Id, updatedTax.Product__c);
    }
}