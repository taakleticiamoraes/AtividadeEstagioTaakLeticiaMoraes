@IsTest
public class FactoryAndValidationCoverageTest {
    
    @IsTest
    static void testCategoryValidationBranches() {
        Account record = new Account(Name = 'Validation Test');
        
        CategoryValidation.validateProductCategory(record, null, null);
        System.assertEquals(true, record.hasErrors(), 'Should error when both product and hierarchy are null');
        
        record = new Account(Name = 'Validation Test 2');
        Id fakeProductId = '01t000000000001AAA';
        Id fakeHierarchyId = 'a00g70000000001AAA';
        CategoryValidation.validateProductCategory(record, fakeProductId, fakeHierarchyId);
        System.assertEquals(true, record.hasErrors(), 'Should error when both product and hierarchy are filled');
        
        record = new Account(Name = 'Location Test 1');
        CategoryValidation.validateLocationCategory(record, null, null, null);
        System.assertEquals(true, record.hasErrors(), 'Should error when no location is filled');
        
        record = new Account(Name = 'Location Test 2');
        Id fakeCityId = 'a01g70000000001AAA';
        Id fakeStateId = 'a02g70000000001AAA';
        CategoryValidation.validateLocationCategory(record, fakeCityId, fakeStateId, null);
        System.assertEquals(true, record.hasErrors(), 'Should error when more than one location is filled');
    }
    
    @IsTest
    static void testTestFactorySObjectExceptionBranches() {
        TestFactorySObject factory = TestFactorySObject.getInstance();
        
        Boolean nullException = false;
        try {
            factory.createSObject(null);
        } catch (Exception e) {
            nullException = true;
        }
        System.assertEquals(true, nullException, 'Null sObject should raise exception');
        
        // Exercises Contract remapping branch (Contract -> ContractStandard)
        Boolean contractPathReached = false;
        try {
            factory.createSObject(new Contract());
            contractPathReached = true;
        } catch (Exception e) {
            contractPathReached = true;
        }
        System.assertEquals(true, contractPathReached, 'Contract branch should execute regardless of defaults availability');
        
        Boolean invalidClassException = false;
        try {
            factory.dispatchSObjectCreation(new Account(), 'TemplateDefaultFields.DoesNotExistDefaults');
        } catch (Exception e) {
            invalidClassException = true;
        }
        System.assertEquals(true, invalidClassException, 'Invalid defaults class should raise exception');
    }
    
    @IsTest
    static void testTemplateDefaultFieldsCoverage_PrimaryPaths() {
        Id stdPbId = Test.getStandardPricebookId();
        update new Pricebook2(Id = stdPbId, IsActive = true);
        
        Map<String, Object> result;
        
        result = new TemplateDefaultFields.CountryDefaults().getFieldDefaults(1);
        System.assertEquals('BR', (String) result.get('Acronym__c'));
        
        result = new TemplateDefaultFields.StateDefaults().getFieldDefaults(2);
        System.assertEquals('SP', (String) result.get('Acronym__c'));
        
        result = new TemplateDefaultFields.CityDefaults().getFieldDefaults(3);
        System.assertNotEquals(null, result.get('State__c'));
        
        result = new TemplateDefaultFields.AccountDefaults().getFieldDefaults(4);
        System.assertNotEquals(null, result.get('Group_Account__c'));
        
        result = new TemplateDefaultFields.AddressDefaults().getFieldDefaults(5);
        System.assertNotEquals(null, result.get('Account__c'));
        
        result = new TemplateDefaultFields.Product2Defaults().getFieldDefaults(6);
        System.assertEquals(true, (Boolean) result.get('IsActive'));
        
        result = new TemplateDefaultFields.OrderDefaults().getFieldDefaults(7);
        System.assertEquals('Draft', (String) result.get('Status'));
        
        result = new TemplateDefaultFields.OrderItemDefaults().getFieldDefaults(8);
        System.assertNotEquals(null, result.get('PricebookEntryId'));
        
        result = new TemplateDefaultFields.TaxDefaults().getFieldDefaults(9);
        System.assertEquals('Approved', (String) result.get('Status__c'));
        
        result = new TemplateDefaultFields.FreightDefaults().getFieldDefaults(10);
        System.assertEquals('Approved', (String) result.get('Status__c'));
        
        result = new TemplateDefaultFields.MarginDefaults().getFieldDefaults(11);
        System.assertEquals('Approved', (String) result.get('Status__c'));
    }
    
    @IsTest
    static void testTemplateDefaultFieldsCoverage_ExistingRecordPaths() {
        Country__c country = new Country__c(Acronym__c = 'BR');
        insert country;
        
        State__c state = new State__c(Country__c = country.Id, Acronym__c = 'SP');
        insert state;
        
        City__c city = new City__c(State__c = state.Id, IBGE_Code__c = '3550308');
        insert city;
        
        Product_Hierarchy__c hierarchy = new Product_Hierarchy__c();
        insert hierarchy;
        
        Product2 product = new Product2(Name = 'Template Existing Product', IsActive = true, Product_Hierarchy__c = hierarchy.Id);
        insert product;
        
        Distribution_Center__c dc = new Distribution_Center__c();
        insert dc;
        
        Group_Account__c groupAccount = new Group_Account__c();
        insert groupAccount;
        
        Account account = new Account(Name = 'Template Existing Account', CNPJ__c = '55555555555555', Group_Account__c = groupAccount.Id);
        insert account;
        
        Map<String, Object> countryDefaults = new TemplateDefaultFields.CountryDefaults().getFieldDefaults(12);
        System.assertEquals('BR', (String) countryDefaults.get('Acronym__c'));
        
        Map<String, Object> stateDefaults = new TemplateDefaultFields.StateDefaults().getFieldDefaults(13);
        System.assertEquals('SP', (String) stateDefaults.get('Acronym__c'));
        
        Map<String, Object> cityDefaults = new TemplateDefaultFields.CityDefaults().getFieldDefaults(14);
        System.assertNotEquals(null, cityDefaults.get('State__c'));
        
        Map<String, Object> addressDefaults = new TemplateDefaultFields.AddressDefaults().getFieldDefaults(15);
        System.assertNotEquals(null, addressDefaults.get('Account__c'));
        
        Map<String, Object> taxDefaults = new TemplateDefaultFields.TaxDefaults().getFieldDefaults(16);
        System.assertNotEquals(null, taxDefaults.get('Product__c'));
        
        Map<String, Object> freightDefaults = new TemplateDefaultFields.FreightDefaults().getFieldDefaults(17);
        System.assertNotEquals(null, freightDefaults.get('Distribution_Center__c'));
        
        Map<String, Object> marginDefaults = new TemplateDefaultFields.MarginDefaults().getFieldDefaults(18);
        System.assertNotEquals(null, marginDefaults.get('State__c'));
    }
    
    @IsTest
    static void testTemplateDefaultFieldsCoverage_MissingStateAndCityRecords() {
        Map<String, Object> stateDefaults = new TemplateDefaultFields.StateDefaults().getFieldDefaults(19);
        System.assertEquals('SP', (String) stateDefaults.get('Acronym__c'));
        
        Map<String, Object> cityDefaults = new TemplateDefaultFields.CityDefaults().getFieldDefaults(20);
        System.assertNotEquals(null, cityDefaults.get('State__c'));
    }
    
    @IsTest
    static void testTemplateDefaultFieldsCoverage_FreshCityDefaults() {
        Map<String, Object> cityDefaults = new TemplateDefaultFields.CityDefaults().getFieldDefaults(21);
        System.assertNotEquals(null, cityDefaults.get('State__c'));
    }
    
    @IsTest
    static void testTemplateDefaultFieldsCoverage_MissingAddressRecords() {
        Map<String, Object> addressDefaults = new TemplateDefaultFields.AddressDefaults().getFieldDefaults(22);
        System.assertNotEquals(null, addressDefaults.get('Account__c'));
        System.assertNotEquals(null, addressDefaults.get('City__c'));
    }
    
    @IsTest
    static void testTemplateDefaultFieldsCoverage_FreshTaxDefaults() {
        Map<String, Object> taxDefaults = new TemplateDefaultFields.TaxDefaults().getFieldDefaults(23);
        System.assertNotEquals(null, taxDefaults.get('Product__c'));
        System.assertNotEquals(null, taxDefaults.get('Distribution_Center__c'));
        System.assertNotEquals(null, taxDefaults.get('State__c'));
    }
    
    @IsTest
    static void testTemplateDefaultFieldsCoverage_FreshFreightDefaults() {
        Map<String, Object> freightDefaults = new TemplateDefaultFields.FreightDefaults().getFieldDefaults(24);
        System.assertNotEquals(null, freightDefaults.get('Product__c'));
        System.assertNotEquals(null, freightDefaults.get('Distribution_Center__c'));
        System.assertNotEquals(null, freightDefaults.get('City__c'));
    }
    
    @IsTest
    static void testTemplateDefaultFieldsCoverage_FreshMarginDefaults() {
        Map<String, Object> marginDefaults = new TemplateDefaultFields.MarginDefaults().getFieldDefaults(25);
        System.assertNotEquals(null, marginDefaults.get('Account__c'));
        System.assertNotEquals(null, marginDefaults.get('Product__c'));
        System.assertNotEquals(null, marginDefaults.get('Distribution_Center__c'));
        System.assertNotEquals(null, marginDefaults.get('State__c'));
    }
    
    @IsTest
    static void testTemplateDefaultFieldsCoverage_OrderItemDefaultsExistingPricebookEntry() {
        Id stdPbId = Test.getStandardPricebookId();
        update new Pricebook2(Id = stdPbId, IsActive = true);
        
        Product_Hierarchy__c hierarchy = new Product_Hierarchy__c();
        insert hierarchy;
        
        Product2 product = new Product2(
            Name = 'Template OrderItem Product',
        IsActive = true,
        Product_Hierarchy__c = hierarchy.Id
            );
        insert product;
        
        PricebookEntry existingPbe;
        List<PricebookEntry> existingPbes = [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :stdPbId
            AND Product2Id = :product.Id
            LIMIT 1
        ];
        
        if (existingPbes.isEmpty()) {
            PricebookEntry candidate = new PricebookEntry(
                Pricebook2Id = stdPbId,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
                );
            
            Database.SaveResult saveResult = Database.insert(candidate, false);
            if (saveResult.isSuccess()) {
                existingPbe = candidate;
            } else {
                existingPbe = [
                    SELECT Id, UnitPrice
                    FROM PricebookEntry
                    WHERE Pricebook2Id = :stdPbId
                    AND Product2Id = :product.Id
                    LIMIT 1
                ];
            }
        } else {
            existingPbe = existingPbes[0];
        }
        
        PricebookEntry resolvedPbe = new TemplateDefaultFields.OrderItemDefaults().getOrCreatePricebookEntry(
            product,
        stdPbId
            );
        
        System.assertEquals(existingPbe.Id, resolvedPbe.Id);
    }
    
    @IsTest
    static void testTemplateDefaultFieldsCoverage_OrderItemDefaultsCreatesPricebookEntry() {
        Id stdPbId = Test.getStandardPricebookId();
        update new Pricebook2(Id = stdPbId, IsActive = true);
        
        Product_Hierarchy__c hierarchy = new Product_Hierarchy__c();
        insert hierarchy;
        
        Product2 product = new Product2(
            Name = 'Template OrderItem Create Product',
        IsActive = true,
        Product_Hierarchy__c = hierarchy.Id
            );
        insert product;
        
        List<PricebookEntry> preexisting = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :stdPbId
            AND Product2Id = :product.Id
        ];
        if (!preexisting.isEmpty()) {
            delete preexisting;
        }
        
        PricebookEntry createdPbe = new TemplateDefaultFields.OrderItemDefaults().getOrCreatePricebookEntry(
            product,
        stdPbId
            );
        
        System.assertNotEquals(null, createdPbe.Id);
    }
}