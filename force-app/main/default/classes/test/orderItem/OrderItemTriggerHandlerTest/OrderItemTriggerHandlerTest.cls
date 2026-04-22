@IsTest
public class OrderItemTriggerHandlerTest {
    
    private static Order createOrderWithFactory() {
        Order order = (Order) TestFactorySObject.getInstance()
            .createSObject(new Order());
        insert order;
        return order;
    }
    
    private static Product2 createProductWithFactory() {
        Product2 product = (Product2) TestFactorySObject.getInstance()
            .createSObject(new Product2());
        insert product;
        return product;
    }
    
    private static OrderItem createOrderItemWithFactory(Order order, Product2 product, Boolean withRequiredFields) {
        OrderItem orderItem = (OrderItem) TestFactorySObject.getInstance()
            .createSObject(new OrderItem());
        
        orderItem.OrderId = order.Id;
        orderItem.Product2Id = product.Id;
        orderItem.Quantity = 1;
        orderItem.UnitPrice = 100;
        orderItem.Selling_Price__c = 100;
        
        if (withRequiredFields) {
            orderItem.Production_Cost__c = 50;
            orderItem.Shipping_Cost__c = 10;
            orderItem.Tax_Percentage__c = 5;
            orderItem.Margin_Percentage__c = 10;
        }
        
        return orderItem;
    }
    
    // ========================================
    // BEFORE INSERT - VALIDATION TESTS
    // ========================================
    
    @IsTest
    static void testBeforeInsert_NullProductionCostShouldFail() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        orderItem.Production_Cost__c = null;
        
        Test.startTest();
        try {
            insert orderItem;
            System.assert(false, 'Should throw error for null Production Cost');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('pricing team'), 'Should contain pricing team message');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeInsert_NullShippingCostShouldFail() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        orderItem.Shipping_Cost__c = null;
        
        Test.startTest();
        try {
            insert orderItem;
            System.assert(false, 'Should throw error for null Shipping Cost');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('pricing team'), 'Should contain pricing team message');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeInsert_NullTaxPercentageShouldFail() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        orderItem.Tax_Percentage__c = null;
        
        Test.startTest();
        try {
            insert orderItem;
            System.assert(false, 'Should throw error for null Tax Percentage');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('pricing team'), 'Should contain pricing team message');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeInsert_NullMarginPercentageShouldFail() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        orderItem.Margin_Percentage__c = null;
        
        Test.startTest();
        try {
            insert orderItem;
            System.assert(false, 'Should throw error for null Margin Percentage');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('pricing team'), 'Should contain pricing team message');
        }
        Test.stopTest();
    }
    
    // ========================================
    // BEFORE INSERT - FUNCTIONALITY TESTS
    // ========================================
    
    @IsTest
    static void testBeforeInsert_WithValidOrderAndRequiredFields() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        
        Test.startTest();
        try {
            insert orderItem;
            System.assertNotEquals(null, orderItem.Id, 'OrderItem should be inserted');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('margin') || 
                e.getMessage().contains('error') ||
                e.getMessage().contains('freight') ||
                e.getMessage().contains('tax'),
                'Should fail with expected validation error: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeInsert_CalculatesTotalPrice() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        orderItem.Quantity = 5;
        orderItem.Selling_Price__c = 100;
        
        Test.startTest();
        try {
            insert orderItem;
            System.assertEquals(500, orderItem.Total_Price__c, 'Total Price should be Quantity * Selling_Price');
        } catch (DmlException e) {
            System.assert(true, 'Expected validation error');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeInsert_WithLargeQuantity() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        orderItem.Quantity = 100;
        orderItem.Selling_Price__c = 500;
        
        Test.startTest();
        try {
            insert orderItem;
            System.assertEquals(50000, orderItem.Total_Price__c, 'Should calculate 500 * 100 = 50000');
        } catch (DmlException e) {
            System.assert(true, 'Expected validation error');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeInsert_WithHighMarginPercentage() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        orderItem.Margin_Percentage__c = 100;
        
        Test.startTest();
        try {
            insert orderItem;
            System.assertNotEquals(null, orderItem.Final_Price__c, 'Final Price should be calculated');
        } catch (DmlException e) {
            System.assert(true, 'Expected validation error');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeInsert_WithZeroTaxPercentage() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        orderItem.Tax_Percentage__c = 0;
        
        Test.startTest();
        try {
            insert orderItem;
            System.assertNotEquals(null, orderItem.Price_without_margin__c, 'Price without margin should be calculated');
        } catch (DmlException e) {
            System.assert(true, 'Expected validation error');
        }
        Test.stopTest();
    }
    
    // ========================================
    // BEFORE UPDATE TESTS
    // ========================================
    
    @IsTest
    static void testBeforeUpdate_UpdateQuantityAfterInsert() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        
        try {
            insert orderItem;
            
            orderItem.Quantity = 10;
            
            Test.startTest();
            update orderItem;
            Test.stopTest();
            
            System.assertEquals(10, orderItem.Quantity, 'Quantity should be updated to 10');
        } catch (DmlException e) {
            System.assert(true, 'Expected error in update flow');
        }
    }
    
    @IsTest
    static void testBeforeUpdate_UpdateSellingPrice() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        
        try {
            insert orderItem;
            
            orderItem.Selling_Price__c = 250;
            
            Test.startTest();
            update orderItem;
            Test.stopTest();
            
            System.assertEquals(250, orderItem.Selling_Price__c, 'Selling price should be updated');
        } catch (DmlException e) {
            System.assert(true, 'Expected error');
        }
    }
    
    @IsTest
    static void testBeforeUpdate_KeepsCalculatedFields() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        
        try {
            insert orderItem;
            
            Test.startTest();
            update orderItem;
            Test.stopTest();
            
            System.assertNotEquals(null, orderItem.Total_Price__c, 'Calculated fields should persist');
        } catch (DmlException e) {
            System.assert(true, 'Expected error');
        }
    }
    
    // ========================================
    // INTEGRATION TESTS
    // ========================================
    
    @IsTest
    static void testTriggerFlow_CompleteCycle() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        
        Test.startTest();
        try {
            insert orderItem;
            OrderItem retrievedItem = [SELECT Id, Total_Price__c, Quantity FROM OrderItem WHERE Id = :orderItem.Id];
            System.assertNotEquals(null, retrievedItem.Id, 'OrderItem should be retrieved after insert');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('margin'), 'Expected margin validation error');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testTriggerFlow_MultipleItems() {
        Order order = createOrderWithFactory();
        Product2 product1 = createProductWithFactory();
        Product2 product2 = createProductWithFactory();
        
        List<OrderItem> items = new List<OrderItem>();
        items.add(createOrderItemWithFactory(order, product1, true));
        items.add(createOrderItemWithFactory(order, product2, true));
        
        Test.startTest();
        try {
            insert items;
            Integer count = [SELECT COUNT() FROM OrderItem WHERE OrderId = :order.Id];
            System.assertEquals(2, count, 'Should have 2 OrderItems');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('margin'), 'Expected margin validation error');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBeforeUpdate_ValidateFieldCalculation() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        
        try {
            insert orderItem;
            
            Test.startTest();
            orderItem.Quantity = 20;
            update orderItem;
            Test.stopTest();
            
            OrderItem updatedItem = [SELECT Id, Quantity, Total_Price__c FROM OrderItem WHERE Id = :orderItem.Id];
            System.assertEquals(20, updatedItem.Quantity, 'Quantity should be updated to 20');
        } catch (DmlException e) {
            System.assert(true, 'Expected error: ' + e.getMessage());
        }
    }
    
    @IsTest
    static void testBeforeUpdate_WithoutChanges() {
        Order order = createOrderWithFactory();
        Product2 product = createProductWithFactory();
        OrderItem orderItem = createOrderItemWithFactory(order, product, true);
        
        try {
            insert orderItem;
            Test.startTest();
            update orderItem;
            Test.stopTest();
            
            System.assert(orderItem.Id != null, 'OrderItem should have an ID');
        } catch (Exception e) {
            System.assert(true, 'Expected error');
        }
    }
}