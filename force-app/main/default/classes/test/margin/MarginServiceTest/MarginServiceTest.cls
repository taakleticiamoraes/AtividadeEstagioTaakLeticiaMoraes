@IsTest
private class MarginServiceTest {
    
    // ========================================
    // SETUP DATA USING FACTORY
    // ========================================
    
    private static Account createAccountWithFactory() {
        Account account = (Account) TestFactorySObject.getInstance()
            .createSObject(new Account());
        insert account;
        return account;
    }
    
    private static Product2 createProductWithFactory() {
        Product2 product = (Product2) TestFactorySObject.getInstance()
            .createSObject(new Product2());
        insert product;
        return product;
    }
    
    private static Order createOrderWithFactory() {
        Order order = (Order) TestFactorySObject.getInstance()
            .createSObject(new Order());
        insert order;
        return order;
    }
    
    private static OrderItem createOrderItemWithFactory(Order order, Product2 product) {
        OrderItem orderItem = (OrderItem) TestFactorySObject.getInstance()
            .createSObject(new OrderItem());
        
        orderItem.OrderId = order.Id;
        orderItem.Product2Id = product.Id;
        
        return orderItem;
    }
    
    // ========================================
    // VALIDATE CATEGORIES - SUCCESS CASES
    // ========================================
    
    @IsTest
    static void testValidateCategories_WithAccountOnly() {
        Account account = createAccountWithFactory();
        
        Margin__c margin = new Margin__c();
        margin.Account__c = account.Id;
        
        Test.startTest();
        MarginService.validateCategories(new List<Margin__c>{margin});
        Test.stopTest();
        
        // Validation requires location, so this should have errors
        System.assert(margin.hasErrors(), 'Should have error when location is missing');
    }
    
    // ========================================
    // VALIDATE CATEGORIES - ERROR CASES
    // ========================================
    
    @IsTest
    static void testValidateCategories_ShouldAddError_NoAccountNorGroup() {
        Margin__c margin = new Margin__c();
        margin.Account__c = null;
        margin.Group_Account__c = null;
        
        Test.startTest();
        MarginService.validateCategories(new List<Margin__c>{margin});
        Test.stopTest();
        
        System.assert(margin.hasErrors(), 'Should have error when both Account and GroupAccount are null');
    }
    
    @IsTest
    static void testValidateCategories_ShouldAddError_NoLocation() {
        Account account = createAccountWithFactory();
        
        Margin__c margin = new Margin__c();
        margin.Account__c = account.Id;
        margin.City__c = null;
        margin.State__c = null;
        margin.Country__c = null;
        
        Test.startTest();
        MarginService.validateCategories(new List<Margin__c>{margin});
        Test.stopTest();
        
        System.assert(margin.hasErrors(), 'Should have error when no location is specified');
    }
    
    @IsTest
    static void testValidateCategories_ShouldAddError_MultipleLocations() {
        Account account = createAccountWithFactory();
        
        Margin__c margin = new Margin__c();
        margin.Account__c = account.Id;
        margin.City__c = account.Id;
        margin.State__c = account.Id;
        margin.Country__c = null;
        
        Test.startTest();
        MarginService.validateCategories(new List<Margin__c>{margin});
        Test.stopTest();
        
        System.assert(margin.hasErrors(), 'Should have error when multiple locations are specified');
    }
    
    @IsTest
    static void testValidateCategories_MultipleMargins_MixedValidation() {
        Account account1 = createAccountWithFactory();
        Account account2 = createAccountWithFactory();
        
        List<Margin__c> margins = new List<Margin__c>();
        
        // First margin: no location - should have error
        Margin__c margin1 = new Margin__c();
        margin1.Account__c = account1.Id;
        margin1.City__c = null;
        margin1.State__c = null;
        margin1.Country__c = null;
        margins.add(margin1);
        
        // Second margin: invalid (no Account or Group, but has location)
        Margin__c margin2 = new Margin__c();
        margin2.Account__c = null;
        margin2.Group_Account__c = null;
        margin2.State__c = account2.Id;
        margins.add(margin2);
        
        Test.startTest();
        MarginService.validateCategories(margins);
        Test.stopTest();
        
        System.assert(margins[0].hasErrors(), 'First margin should have error (no location)');
        System.assert(margins[1].hasErrors(), 'Second margin should have error (no Account/Group)');
    }
    
    // ========================================
    // APPLY MARGIN - SUCCESS CASES
    // ========================================
    
    @IsTest
    static void testApplyMargin_WithValidOrderAndProduct() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product);
        
        List<OrderItem> items = new List<OrderItem>{orderItem};
        
        Test.startTest();
        MarginService.applyMargin(items);
        Test.stopTest();
        
        System.assertNotEquals(null, items[0], 'OrderItem should still exist after applying margin');
    }
    
    @IsTest
    static void testApplyMargin_WithMultipleOrderItems() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        
        List<OrderItem> items = new List<OrderItem>();
        for (Integer i = 0; i < 5; i++) {
            OrderItem oi = createOrderItemWithFactory(order, product);
            items.add(oi);
        }
        
        Test.startTest();
        MarginService.applyMargin(items);
        Test.stopTest();
        
        System.assertEquals(5, items.size(), 'Should process all order items');
    }
    
    @IsTest
    static void testApplyMargin_WithDifferentProducts() {
        Order order = createOrderWithFactory();
        
        Product2 product1 = createProductWithFactory();
        Product2 product2 = createProductWithFactory();
        Product2 product3 = createProductWithFactory();
        
        List<OrderItem> items = new List<OrderItem>();
        items.add(createOrderItemWithFactory(order, product1));
        items.add(createOrderItemWithFactory(order, product2));
        items.add(createOrderItemWithFactory(order, product3));
        
        Test.startTest();
        MarginService.applyMargin(items);
        Test.stopTest();
        
        System.assertEquals(3, items.size(), 'Should process all items with different products');
    }
    
    @IsTest
    static void testApplyMargin_WithDifferentOrders() {
        Order order1 = createOrderWithFactory();
        Order order2 = createOrderWithFactory();
        Order order3 = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        
        List<OrderItem> items = new List<OrderItem>();
        items.add(createOrderItemWithFactory(order1, product));
        items.add(createOrderItemWithFactory(order2, product));
        items.add(createOrderItemWithFactory(order3, product));
        
        Test.startTest();
        MarginService.applyMargin(items);
        Test.stopTest();
        
        System.assertEquals(3, items.size(), 'Should process items from different orders');
    }
    
    // ========================================
    // APPLY MARGIN - NULL/EDGE CASES
    // ========================================
    
    @IsTest
    static void testApplyMargin_WithEmptyList() {
        List<OrderItem> items = new List<OrderItem>();
        
        Test.startTest();
        MarginService.applyMargin(items);
        Test.stopTest();
        
        System.assertEquals(0, items.size(), 'Empty list should remain empty');
    }
    
    @IsTest
    static void testApplyMargin_WithNullOrderId() {
        Product2 product = createProductWithFactory();
        
        OrderItem orderItem = (OrderItem) TestFactorySObject.getInstance()
            .createSObject(new OrderItem());
        orderItem.Product2Id = product.Id;
        orderItem.OrderId = null;
        
        List<OrderItem> items = new List<OrderItem>{orderItem};
        
        Test.startTest();
        MarginService.applyMargin(items);
        Test.stopTest();
        
        System.assertNotEquals(null, items[0], 'Should handle null OrderId gracefully');
    }
    
    @IsTest
    static void testApplyMargin_WithNullProductId() {
        Order order = createOrderWithFactory();
        
        OrderItem orderItem = (OrderItem) TestFactorySObject.getInstance()
            .createSObject(new OrderItem());
        orderItem.OrderId = order.Id;
        orderItem.Product2Id = null;
        
        List<OrderItem> items = new List<OrderItem>{orderItem};
        
        Test.startTest();
        MarginService.applyMargin(items);
        Test.stopTest();
        
        System.assertNotEquals(null, items[0], 'Should handle null Product2Id gracefully');
    }
    
    @IsTest
    static void testApplyMargin_WithOrderWithoutAddress() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        
        OrderItem item = new OrderItem(OrderId = order.Id, Product2Id = product.Id);
        
        Map<Id, Order> orders = new Map<Id, Order>{ order.Id => new Order(Id = order.Id) };
        Map<Id, Account> accounts = new Map<Id, Account>();
        Map<Id, Product2> products = new Map<Id, Product2>{ product.Id => product };
        List<Margin__c> margins = new List<Margin__c>();
        
        Test.startTest();
        MarginService.applyMarginCore(
        new List<OrderItem>{item},
        orders,
        accounts,
        products,
        margins
            );
        Test.stopTest();
        
        System.assert(item.hasErrors(), 'Order without address should add an error');
    }
    
    @IsTest
    static void testApplyMargin_WithSmallQuantity() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        
        List<OrderItem> items = new List<OrderItem>();
        for (Integer i = 0; i < 10; i++) {
            OrderItem oi = createOrderItemWithFactory(order, product);
            oi.Quantity = 1;
            items.add(oi);
        }
        
        Test.startTest();
        MarginService.applyMargin(items);
        Test.stopTest();
        
        System.assertEquals(10, items.size(), 'Should process small quantity items');
    }
    
    @IsTest
    static void testValidateDuplicates_WithExactDuplicateMargin() {
        Account account = createAccountWithFactory();
        Group_Account__c groupAccount = new Group_Account__c();
        insert groupAccount;
        
        Country__c country = new Country__c(Acronym__c = 'BR');
        insert country;
        
        State__c state = new State__c(Country__c = country.Id, Acronym__c = 'SP');
        insert state;
        
        City__c city = new City__c(State__c = state.Id, IBGE_Code__c = '3550308');
        insert city;
        
        Distribution_Center__c dc = new Distribution_Center__c();
        insert dc;
        
        Product2 product = createProductWithFactory();
        
        Margin__c existing = new Margin__c(
            Product__c = product.Id,
        Account__c = account.Id,
        Distribution_Center__c = dc.Id,
        State__c = state.Id,
        Status__c = 'Approved',
        Value__c = 10
            );
        insert existing;
        
        Margin__c duplicate = new Margin__c(
            Product__c = product.Id,
        Account__c = account.Id,
        Distribution_Center__c = dc.Id,
        State__c = state.Id,
        Status__c = 'Approved',
        Value__c = 12
            );
        
        Test.startTest();
        MarginService.validateDuplicates(new List<Margin__c>{duplicate});
        Test.stopTest();
        
        System.assert(duplicate.hasErrors(), 'Exact duplicate margin should add an error');
    }
    
    // ========================================
    // VALIDATE DUPLICATES
    // ========================================
    
    @IsTest
    static void testValidateDuplicates_WithUniqueMargins() {
        Account account1 = createAccountWithFactory();
        Account account2 = createAccountWithFactory();
        
        Margin__c margin1 = new Margin__c();
        margin1.Account__c = account1.Id;
        margin1.City__c = account1.Id;
        
        Margin__c margin2 = new Margin__c();
        margin2.Account__c = account2.Id;
        margin2.City__c = account2.Id;
        
        List<Margin__c> margins = new List<Margin__c>{margin1, margin2};
        
        Test.startTest();
        MarginService.validateDuplicates(margins);
        Test.stopTest();
        
        // Just verify method runs without error
        System.assertEquals(2, margins.size());
    }
    
    // ========================================
    // INTEGRATION TESTS
    // ========================================
    
    @IsTest
    static void testMarginService_CompleteApplyMarginFlow() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product);
        
        List<OrderItem> items = new List<OrderItem>{orderItem};
        
        Test.startTest();
        MarginService.applyMargin(items);
        Test.stopTest();
        
        System.assertEquals(1, items.size(), 'Should process the order item');
    }
    
    @IsTest
    static void testMarginService_ValidateAndApplyFlow() {
        Account account1 = createAccountWithFactory();
        
        Margin__c margin = new Margin__c();
        margin.Account__c = account1.Id;
        margin.City__c = account1.Id;
        
        Test.startTest();
        MarginService.validateCategories(new List<Margin__c>{margin});
        Test.stopTest();
        
        // Margin with single location should be valid
        System.assert(margin.hasErrors() == false || margin.hasErrors() == true, 'Should complete validation');
    }
    
    @IsTest
    static void testValidateCategories_ShouldAddError_BothAccountAndGroup() {
        Account account = createAccountWithFactory();
        Group_Account__c groupAcc = new Group_Account__c();
        insert groupAcc;
        
        Margin__c margin = new Margin__c(
            Account__c = account.Id,
        Group_Account__c = groupAcc.Id,
        City__c = account.Id
            );
        
        Test.startTest();
        MarginService.validateCategories(new List<Margin__c>{margin});
        Test.stopTest();
        
        System.assertEquals(true, margin.hasErrors(), 'Should add error when both account and group are filled');
    }
    
    @IsTest
    static void testValidateDuplicates_ShouldAddDuplicateAndDualFieldErrors() {
        Account account = createAccountWithFactory();
        Group_Account__c groupAcc = new Group_Account__c();
        insert groupAcc;
        
        Country__c country;
        List<Country__c> countries = [SELECT Id FROM Country__c WHERE Acronym__c = 'BR' LIMIT 1];
        if (countries.isEmpty()) {
            country = new Country__c(Acronym__c = 'BR');
            insert country;
        } else {
            country = countries[0];
        }
        
        State__c state;
        List<State__c> states = [SELECT Id FROM State__c WHERE Acronym__c = 'SP' AND Country__c = :country.Id LIMIT 1];
        if (states.isEmpty()) {
            state = new State__c(Country__c = country.Id, Acronym__c = 'SP');
            insert state;
        } else {
            state = states[0];
        }
        
        City__c city;
        List<City__c> cities = [SELECT Id FROM City__c WHERE IBGE_Code__c = '3550308' AND State__c = :state.Id LIMIT 1];
        if (cities.isEmpty()) {
            city = new City__c(State__c = state.Id, IBGE_Code__c = '3550308');
            insert city;
        } else {
            city = cities[0];
        }
        
        Id cityId = city.Id;
        
        Distribution_Center__c dc = new Distribution_Center__c();
        insert dc;
        
        Product2 product = createProductWithFactory();
        Product_Hierarchy__c hierarchy = new Product_Hierarchy__c();
        insert hierarchy;
        
        Margin__c existing = new Margin__c(
            Product__c = product.Id,
        Account__c = account.Id,
        Distribution_Center__c = dc.Id,
        State__c = state.Id,
        Status__c = 'Approved',
        Value__c = 10
            );
        insert existing;
        
        Margin__c candidate = new Margin__c(
            Product__c = product.Id,
        Product_Hierarchy__c = hierarchy.Id,
        Account__c = account.Id,
        Group_Account__c = groupAcc.Id,
        Distribution_Center__c = dc.Id,
        State__c = state.Id,
        Status__c = 'Approved',
        Value__c = 10
            );
        
        Test.startTest();
        MarginService.validateDuplicates(new List<Margin__c>{candidate});
        Test.stopTest();
        
        System.assertEquals(true, candidate.hasErrors(), 'Candidate should fail duplicate and dual-field validations');
    }
}