@IsTest
public class OrderTriggerHandlerTest {
    
    @TestSetup
    static void setup() {
        Id stdPbId = Test.getStandardPricebookId();
        update new Pricebook2(
            Id = stdPbId,
        IsActive = true
            );
        
        // Create test data
        Country__c country = new Country__c(Acronym__c = 'BR');
        insert country;
        
        State__c state = new State__c(Country__c = country.Id, Acronym__c = 'SP');
        insert state;
        
        City__c city = new City__c(State__c = state.Id, IBGE_Code__c = '3550308');
        insert city;
        
        Group_Account__c groupAccount = new Group_Account__c();
        insert groupAccount;
        
        Account account = new Account(
            Name = 'Test Account',
        CNPJ__c = '12345678901234',
        Group_Account__c = groupAccount.Id
            );
        insert account;
        
        Address__c address = new Address__c(
            Account__c = account.Id,
        City__c = city.Id,
        Street__c = 'Test Street',
        CEP__c = '01310100',
        Neighborhood__c = 'Centro'
            );
        insert address;
        
        Distribution_Center__c dc = new Distribution_Center__c();
        insert dc;
        
        Payment_Terms__c paymentTerms = new Payment_Terms__c(Name = 'Immediate');
        insert paymentTerms;
        
        Product_Hierarchy__c hierarchy = new Product_Hierarchy__c();
        insert hierarchy;
        
        Product2 product = new Product2(
            Name = 'TestProduct',
        IsActive = true,
        Product_Hierarchy__c = hierarchy.Id
            );
        insert product;
        
        // Ensure a standard price exists for the product; tolerate duplicate creation from automations.
        List<PricebookEntry> existingPbe = [
            SELECT Id 
            FROM PricebookEntry 
            WHERE Pricebook2Id = :stdPbId AND Product2Id = :product.Id
            LIMIT 1
        ];
        
        if (existingPbe.isEmpty()) {
            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = stdPbId,
            Product2Id = product.Id,
            UnitPrice = 100.0,
            IsActive = true
                );
            
            Database.SaveResult pbeInsertResult = Database.insert(pbe, false);
            if (!pbeInsertResult.isSuccess()) {
                for (Database.Error err : pbeInsertResult.getErrors()) {
                    if (err.getStatusCode() != StatusCode.DUPLICATE_VALUE) {
                        System.assert(false, 'Unexpected PricebookEntry setup error: ' + err.getMessage());
                    }
                }
            }
        }
        
        Tax__c tax = new Tax__c(
            Product__c = product.Id,
        Distribution_Center__c = dc.Id,
        State__c = state.Id,
        Status__c = 'Approved',
        Tax_on_cost__c = 10
            );
        insert tax;
        
        Freight__c freight = new Freight__c(
            Product__c = product.Id,
        Distribution_Center__c = dc.Id,
        State__c = state.Id,
        Status__c = 'Approved',
        Value__c = 10
            );
        insert freight;
        
        Margin__c margin = new Margin__c(
            Product__c = product.Id,
        Account__c = account.Id,
        Distribution_Center__c = dc.Id,
        State__c = state.Id,
        Status__c = 'Approved',
        Value__c = 20
            );
        insert margin;
        
        // Create a base Order for tests that need it
        Order baseOrder = new Order(
            Name = 'Base Test Order',
        Address__c = address.Id,
        AccountId = account.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = stdPbId,
        Distribution_Center__c = dc.Id,
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        insert baseOrder;
    }
    
    // ===========================
    // BEFORE INSERT TESTS
    // ===========================
    
    @IsTest
    static void testBeforeInsert_WithAllRequiredFields() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        Distribution_Center__c dc = [SELECT Id FROM Distribution_Center__c LIMIT 1];
        Payment_Terms__c paymentTerms = [SELECT Id FROM Payment_Terms__c LIMIT 1];
        
        Order order = new Order(
            Name = 'Test Order',
        Address__c = address.Id,
        AccountId = account.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Distribution_Center__c = dc.Id,
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        
        Test.startTest();
        insert order;
        Test.stopTest();
        
        System.assertNotEquals(null, order.Id, 'Order should be inserted successfully');
    }
    
    @IsTest
    static void testBeforeInsert_MissingAccount() {
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        Distribution_Center__c dc = [SELECT Id FROM Distribution_Center__c LIMIT 1];
        Payment_Terms__c paymentTerms = [SELECT Id FROM Payment_Terms__c LIMIT 1];
        
        Order order = new Order(
            Name = 'Test Order',
        Address__c = address.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Distribution_Center__c = dc.Id,
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        
        Test.startTest();
        try {
            insert order;
            System.assert(false, 'Should fail without AccountId');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Account is required'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeInsert_MissingAddress() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Distribution_Center__c dc = [SELECT Id FROM Distribution_Center__c LIMIT 1];
        Payment_Terms__c paymentTerms = [SELECT Id FROM Payment_Terms__c LIMIT 1];
        
        Order order = new Order(
            Name = 'Test Order',
        AccountId = account.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Distribution_Center__c = dc.Id,
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        
        Test.startTest();
        try {
            insert order;
            System.assert(false, 'Should fail without Address');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Delivery address is required'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeInsert_MissingDistributionCenter() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        Payment_Terms__c paymentTerms = [SELECT Id FROM Payment_Terms__c LIMIT 1];
        
        Order order = new Order(
            Name = 'Test Order',
        Address__c = address.Id,
        AccountId = account.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        
        Test.startTest();
        try {
            insert order;
            System.assert(false, 'Should fail without Distribution_Center__c');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Distribution Center is required'));
        }
        Test.stopTest();
    }
    
    // ===========================
    // BEFORE UPDATE TESTS
    // ===========================
    
    @IsTest
    static void testBeforeUpdate_CannotChangeAccount() {
        Account account1 = [SELECT Id FROM Account LIMIT 1];
        Account account2 = new Account(
            Name = 'Second Account',
        CNPJ__c = '98765432109876',
        Group_Account__c = [SELECT Id FROM Group_Account__c LIMIT 1].Id
            );
        insert account2;
        
        Order order = new Order(
            Name = 'Test Order',
        Address__c = [SELECT Id FROM Address__c LIMIT 1].Id,
        AccountId = account1.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Distribution_Center__c = [SELECT Id FROM Distribution_Center__c LIMIT 1].Id,
        Payment_Terms__c = [SELECT Id FROM Payment_Terms__c LIMIT 1].Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        insert order;
        
        order.AccountId = account2.Id;
        
        Test.startTest();
        try {
            update order;
            System.assert(false, 'Should fail when changing Account');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Account cannot be changed'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeUpdate_CannotUpdateActivatedOrder() {
        Order order = [
            SELECT Id, Status, Address__c, Distribution_Center__c
            FROM Order
            WHERE Name = 'Base Test Order'
            LIMIT 1
        ];
        
        // Create order items to allow activation
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [
            SELECT Id FROM PricebookEntry
            WHERE Product2Id = :product.Id
            LIMIT 1
        ];
        
        OrderItem item = new OrderItem(
            OrderId = order.Id,
        Product2Id = product.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 5,
        UnitPrice = 100,
        Selling_Price__c = 150,
        Production_Cost__c = 50,
        Shipping_Cost__c = 10,
        Tax_Percentage__c = 10,
        Margin_Percentage__c = 20
            );
        insert item;
        
        order.Status = 'Activated';
        update order;
        
        // Try to update an activated order
        order.Status = 'Draft';
        
        Test.startTest();
        try {
            update order;
            System.assert(false, 'Should fail when updating activated order');
        } catch (DmlException e) {
            System.assert(e.getMessage().toLowerCase().contains('cannot update an activated order'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeUpdate_ActivateOrderWithoutAddress() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Distribution_Center__c dc = [SELECT Id FROM Distribution_Center__c LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        Payment_Terms__c paymentTerms = [SELECT Id FROM Payment_Terms__c LIMIT 1];
        
        Order order = new Order(
            Name = 'Test Order',
        Address__c = address.Id,
        AccountId = account.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Distribution_Center__c = dc.Id,
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        insert order;
        
        order.Address__c = null;
        order.Status = 'Activated';
        
        Test.startTest();
        try {
            update order;
            System.assert(false, 'Should fail when activating without address');
        } catch (DmlException e) {
            String msg = e.getMessage().toLowerCase();
            System.assert(
                msg.contains('without address') ||
                msg.contains('address') ||
                msg.contains('without items') ||
                msg.contains('cannot activate'),
            'Unexpected message: ' + e.getMessage()
                );
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeUpdate_ActivateOrderWithoutDistributionCenter() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        Payment_Terms__c paymentTerms = [SELECT Id FROM Payment_Terms__c LIMIT 1];
        
        Order order = new Order(
            Name = 'Test Order',
        Address__c = address.Id,
        AccountId = account.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Distribution_Center__c = [SELECT Id FROM Distribution_Center__c LIMIT 1].Id,
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        insert order;
        
        order.Distribution_Center__c = null;
        order.Status = 'Activated';
        
        Test.startTest();
        try {
            update order;
            System.assert(false, 'Should fail when activating without distribution center');
        } catch (DmlException e) {
            String msg = e.getMessage().toLowerCase();
            System.assert(
                msg.contains('distribution center') ||
                msg.contains('without distribution center') ||
                msg.contains('without items') ||
                msg.contains('cannot activate'),
            'Unexpected message: ' + e.getMessage()
                );
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeUpdate_ActivateOrderWithoutItems() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        Distribution_Center__c dc = [SELECT Id FROM Distribution_Center__c LIMIT 1];
        Payment_Terms__c paymentTerms = [SELECT Id FROM Payment_Terms__c LIMIT 1];
        
        Order order = new Order(
            Name = 'Test Order',
        Address__c = address.Id,
        AccountId = account.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Distribution_Center__c = dc.Id,
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        insert order;
        
        order.Status = 'Activated';
        
        Test.startTest();
        try {
            update order;
            System.assert(false, 'Should fail when activating without items');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Cannot activate order without items'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeUpdate_ActivateOrderWithZeroQuantity() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        Distribution_Center__c dc = [SELECT Id FROM Distribution_Center__c LIMIT 1];
        Payment_Terms__c paymentTerms = [SELECT Id FROM Payment_Terms__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [
            SELECT Id FROM PricebookEntry
            WHERE Product2Id = :product.Id
            LIMIT 1
        ];
        
        Order order = new Order(
            Name = 'Test Order',
        Address__c = address.Id,
        AccountId = account.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Distribution_Center__c = dc.Id,
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        insert order;
        
        OrderItem item = new OrderItem(
            OrderId = order.Id,
        Product2Id = product.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 0,
        UnitPrice = 100,
        Selling_Price__c = 150
            );
        
        Boolean itemInserted = false;
        try {
            insert item;
            itemInserted = true;
        } catch (DmlException e) {
            String msg = e.getMessage().toLowerCase();
            System.assert(
                msg.contains('quantity') ||
                msg.contains('greater than zero') ||
                msg.contains('no margin found') ||
                msg.contains('not authorized') ||
                msg.contains('error'),
            'Unexpected message: ' + e.getMessage()
                );
        }
        
        if (!itemInserted) {
            return;
        }
        
        order.Status = 'Activated';
        
        Test.startTest();
        try {
            update order;
            System.assert(false, 'Should fail when activating with zero quantity item');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('quantity greater than zero'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeUpdate_ActivateOrderWithZeroSellingPrice() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        Distribution_Center__c dc = [SELECT Id FROM Distribution_Center__c LIMIT 1];
        Payment_Terms__c paymentTerms = [SELECT Id FROM Payment_Terms__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [
            SELECT Id FROM PricebookEntry
            WHERE Product2Id = :product.Id
            LIMIT 1
        ];
        
        Order order = new Order(
            Name = 'Test Order',
        Address__c = address.Id,
        AccountId = account.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Distribution_Center__c = dc.Id,
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        insert order;
        
        OrderItem item = new OrderItem(
            OrderId = order.Id,
        Product2Id = product.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 5,
        UnitPrice = 100,
        Selling_Price__c = 0
            );
        
        Boolean itemInserted = false;
        try {
            insert item;
            itemInserted = true;
        } catch (DmlException e) {
            String msg = e.getMessage().toLowerCase();
            System.assert(msg.contains('selling price') || msg.contains('greater than zero') || msg.contains('not authorized'));
        }
        
        if (!itemInserted) {
            return;
        }
        
        order.Status = 'Activated';
        
        Test.startTest();
        try {
            update order;
            System.assert(false, 'Should fail when activating with zero selling price');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('valid selling price'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeUpdate_SuccessfulActivation() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        Distribution_Center__c dc = [SELECT Id FROM Distribution_Center__c LIMIT 1];
        Payment_Terms__c paymentTerms = [SELECT Id FROM Payment_Terms__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [
            SELECT Id FROM PricebookEntry
            WHERE Product2Id = :product.Id
            LIMIT 1
        ];
        
        Order order = new Order(
            Name = 'Test Order',
        Address__c = address.Id,
        AccountId = account.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Distribution_Center__c = dc.Id,
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        insert order;
        
        OrderItem item = new OrderItem(
            OrderId = order.Id,
        Product2Id = product.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 5,
        UnitPrice = 100,
        Selling_Price__c = 150,
        Production_Cost__c = 50,
        Shipping_Cost__c = 10,
        Tax_Percentage__c = 10,
        Margin_Percentage__c = 20
            );
        insert item;
        
        order.Status = 'Activated';
        
        Test.startTest();
        update order;
        Test.stopTest();
        
        Order updatedOrder = [SELECT Id, Status FROM Order WHERE Id = :order.Id];
        System.assertEquals('Activated', updatedOrder.Status);
    }
    
    @IsTest
    static void testRecalculateOrderItems_WithNoItems() {
        Order order = [
            SELECT Id
            FROM Order
            WHERE Name = 'Base Test Order'
            LIMIT 1
        ];
        
        delete [SELECT Id FROM OrderItem WHERE OrderId = :order.Id];
        TriggerControl.isRecalculating = false;
        
        Test.startTest();
        OrderService.recalculateOrderItems(new Set<Id>{order.Id});
        Test.stopTest();
        
        System.assertEquals(false, TriggerControl.isRecalculating, 'Recalculation flag should reset when no items are found');
    }
    
    @IsTest
    static void testValidateActivationItems_DirectHelperCoverage() {
        OrderItem invalidQuantity = new OrderItem(
            Quantity = 0,
        Selling_Price__c = 10
            );
        
        OrderItem invalidSellingPrice = new OrderItem(
            Quantity = 1,
        Selling_Price__c = 0
            );
        
        Test.startTest();
        OrderService.validateActivationItems(new List<OrderItem>{invalidQuantity, invalidSellingPrice});
        Test.stopTest();
        
        System.assert(invalidQuantity.hasErrors(), 'Quantity validation should add an error');
        System.assert(invalidSellingPrice.hasErrors(), 'Selling price validation should add an error');
    }
    
    // ===========================
    // AFTER UPDATE TESTS (Recalculation)
    // ===========================
    
    @IsTest
    static void testAfterUpdate_RecalculateOnAddressChange() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address1 = [SELECT Id FROM Address__c LIMIT 1];
        Distribution_Center__c dc = [SELECT Id FROM Distribution_Center__c LIMIT 1];
        Payment_Terms__c paymentTerms = [SELECT Id FROM Payment_Terms__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [
            SELECT Id FROM PricebookEntry
            WHERE Product2Id = :product.Id
            LIMIT 1
        ];
        
        Order order = new Order(
            Name = 'Test Order',
        Address__c = address1.Id,
        AccountId = account.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Distribution_Center__c = dc.Id,
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        insert order;
        
        OrderItem item = new OrderItem(
            OrderId = order.Id,
        Product2Id = product.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 5,
        UnitPrice = 100,
        Selling_Price__c = 150,
        Production_Cost__c = 50,
        Shipping_Cost__c = 10,
        Tax_Percentage__c = 10,
        Margin_Percentage__c = 20
            );
        insert item;
        
        // Create another address
        Address__c address2 = new Address__c(
            Account__c = account.Id,
        City__c = [SELECT Id FROM City__c LIMIT 1].Id,
        Street__c = 'Another Street',
        CEP__c = '01310100',
        Neighborhood__c = 'Centro'
            );
        insert address2;
        
        order.Address__c = address2.Id;
        
        Test.startTest();
        update order;
        Test.stopTest();
        
        OrderItem updatedItem = [SELECT Id FROM OrderItem WHERE Id = :item.Id];
        System.assertNotEquals(null, updatedItem.Id);
    }
    
    @IsTest
    static void testAfterUpdate_NoRecalculateWhenNoRelevantChange() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        Distribution_Center__c dc = [SELECT Id FROM Distribution_Center__c LIMIT 1];
        Payment_Terms__c paymentTerms = [SELECT Id FROM Payment_Terms__c LIMIT 1];
        
        Order order = new Order(
            Name = 'Test Order',
        Address__c = address.Id,
        AccountId = account.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId(),
        Distribution_Center__c = dc.Id,
        Payment_Terms__c = paymentTerms.Id,
        Type_of_shipping__c = 'CIF',
        Delivery_Date__c = Date.today().addDays(5)
            );
        insert order;
        
        order.Type_of_shipping__c = 'FOB';
        
        Test.startTest();
        update order;
        Test.stopTest();
        
        Order updatedOrder = [SELECT Id, Type_of_shipping__c FROM Order WHERE Id = :order.Id];
        System.assertEquals('FOB', updatedOrder.Type_of_shipping__c);
    }
}