@IsTest
public class ScoringServiceTest {
    
    // Helper method to generate consistent fake IDs for testing
    private static Id getFakeId(Schema.SObjectType sObjType) {
        String keyPrefix = sObjType.getDescribe().getKeyPrefix();
        String fakeIdString = keyPrefix + '0'.repeat(12);
        return Id.valueOf(fakeIdString);
    }
    
    // ========================================
    // CALCULATE FREIGHT SCORE - BASIC TESTS
    // ========================================
    
    @IsTest
    static void testCalculateFreightScore_WithProductMatch() {
        Id productId = getFakeId(Product2.SObjectType);
        Id dcId = getFakeId(Distribution_Center__c.SObjectType);
        
        Freight__c freight = new Freight__c();
        freight.Product__c = productId;
        freight.Distribution_Center__c = dcId;
        
        Test.startTest();
        Integer score = ScoringService.calculateFreightScore(
            freight,
            productId,
            null,
            dcId,
            null,
            null,
            null
        );
        Test.stopTest();
        
        System.assertEquals(100, score, 'Product match should score 100');
    }
    
    @IsTest
    static void testCalculateFreightScore_WithProductMismatch() {
        // Create two different fake IDs by using different counters
        String prefix1 = Product2.SObjectType.getDescribe().getKeyPrefix();
        String prefix2 = Product2.SObjectType.getDescribe().getKeyPrefix();
        Id productId1 = Id.valueOf(prefix1 + '0'.repeat(12));
        Id productId2 = Id.valueOf(prefix2 + '0'.repeat(11) + '1');
        Id dcId = getFakeId(Distribution_Center__c.SObjectType);
        
        Freight__c freight = new Freight__c();
        freight.Product__c = productId1;
        freight.Distribution_Center__c = dcId;
        
        Test.startTest();
        Integer score = ScoringService.calculateFreightScore(
            freight,
            productId2,
            null,
            dcId,
            null,
            null,
            null
        );
        Test.stopTest();
        
        System.assertEquals(-1, score, 'Product mismatch should return -1');
    }
    
    @IsTest
    static void testCalculateFreightScore_WithHierarchyMatch() {
        Id hierarchyId = getFakeId(Product_Hierarchy__c.SObjectType);
        Id dcId = getFakeId(Distribution_Center__c.SObjectType);
        
        Freight__c freight = new Freight__c();
        freight.Product__c = null;
        freight.Product_Hierarchy__c = hierarchyId;
        freight.Distribution_Center__c = dcId;
        
        Test.startTest();
        Integer score = ScoringService.calculateFreightScore(
            freight,
            null,
            hierarchyId,
            dcId,
            null,
            null,
            null
        );
        Test.stopTest();
        
        System.assertEquals(50, score, 'Hierarchy match should score 50');
    }
    
    @IsTest
    static void testCalculateFreightScore_WithDistributionCenterMismatch() {
        Id productId = getFakeId(Product2.SObjectType);
        String dcPrefix = Distribution_Center__c.SObjectType.getDescribe().getKeyPrefix();
        Id dcId1 = Id.valueOf(dcPrefix + '0'.repeat(12));
        Id dcId2 = Id.valueOf(dcPrefix + '0'.repeat(11) + '1');
        
        Freight__c freight = new Freight__c();
        freight.Product__c = productId;
        freight.Distribution_Center__c = dcId1;
        
        Test.startTest();
        Integer score = ScoringService.calculateFreightScore(
            freight,
            productId,
            null,
            dcId2,
            null,
            null,
            null
        );
        Test.stopTest();
        
        System.assertEquals(-1, score, 'Distribution center mismatch should return -1');
    }
    
    @IsTest
    static void testCalculateFreightScore_WithCityLocation() {
        Id dcId = getFakeId(Distribution_Center__c.SObjectType);
        Id cityId = getFakeId(City__c.SObjectType);
        
        Freight__c freight = new Freight__c();
        freight.Product__c = null;
        freight.Product_Hierarchy__c = null;
        freight.Distribution_Center__c = dcId;
        freight.City__c = cityId;
        
        Test.startTest();
        Integer score = ScoringService.calculateFreightScore(
            freight,
            null,
            null,
            dcId,
            cityId,
            null,
            null
        );
        Test.stopTest();
        
        System.assertEquals(30, score, 'City location should score 30');
    }
    
    @IsTest
    static void testCalculateFreightScore_WithStateLocation() {
        Id dcId = getFakeId(Distribution_Center__c.SObjectType);
        Id stateId = getFakeId(State__c.SObjectType);
        
        Freight__c freight = new Freight__c();
        freight.Distribution_Center__c = dcId;
        freight.State__c = stateId;
        
        Test.startTest();
        Integer score = ScoringService.calculateFreightScore(
            freight,
            null,
            null,
            dcId,
            null,
            stateId,
            null
        );
        Test.stopTest();
        
        System.assertEquals(20, score, 'State location should score 20');
    }
    
    @IsTest
    static void testCalculateFreightScore_WithCountryLocation() {
        Id dcId = getFakeId(Distribution_Center__c.SObjectType);
        Id countryId = getFakeId(Country__c.SObjectType);
        
        Freight__c freight = new Freight__c();
        freight.Distribution_Center__c = dcId;
        freight.Country__c = countryId;
        
        Test.startTest();
        Integer score = ScoringService.calculateFreightScore(
            freight,
            null,
            null,
            dcId,
            null,
            null,
            countryId
        );
        Test.stopTest();
        
        System.assertEquals(10, score, 'Country location should score 10');
    }
    
    // ========================================
    // CALCULATE MARGIN SCORE - BASIC TESTS
    // ========================================
    
    @IsTest
    static void testCalculateMarginScore_WithProductMatch() {
        Id productId = getFakeId(Product2.SObjectType);
        Id accountId = getFakeId(Account.SObjectType);
        
        Margin__c margin = new Margin__c();
        margin.Product__c = productId;
        margin.Account__c = accountId;
        
        Test.startTest();
        Integer score = ScoringService.calculateMarginScore(
            margin,
            productId,
            null,
            accountId,
            null,
            null,
            null,
            null
        );
        Test.stopTest();
        
        System.assertEquals(160, score, 'Product (100) + Account (60) should score 160');
    }
    
    @IsTest
    static void testCalculateMarginScore_WithProductMismatch() {
        String prefix = Product2.SObjectType.getDescribe().getKeyPrefix();
        Id productId1 = Id.valueOf(prefix + '0'.repeat(12));
        Id productId2 = Id.valueOf(prefix + '0'.repeat(11) + '1');
        Id accountId = getFakeId(Account.SObjectType);
        
        Margin__c margin = new Margin__c();
        margin.Product__c = productId1;
        margin.Account__c = accountId;
        
        Test.startTest();
        Integer score = ScoringService.calculateMarginScore(
            margin,
            productId2,
            null,
            accountId,
            null,
            null,
            null,
            null
        );
        Test.stopTest();
        
        System.assertEquals(-1, score, 'Product mismatch should return -1');
    }
    
    @IsTest
    static void testCalculateMarginScore_WithHierarchyMatch() {
        Id hierarchyId = getFakeId(Product_Hierarchy__c.SObjectType);
        Id accountId = getFakeId(Account.SObjectType);
        
        Margin__c margin = new Margin__c();
        margin.Product__c = null;
        margin.Product_Hierarchy__c = hierarchyId;
        margin.Account__c = accountId;
        
        Test.startTest();
        Integer score = ScoringService.calculateMarginScore(
            margin,
            null,
            hierarchyId,
            accountId,
            null,
            null,
            null,
            null
        );
        Test.stopTest();
        
        System.assertEquals(140, score, 'Hierarchy (80) + Account (60) should score 140');
    }
    
    @IsTest
    static void testCalculateMarginScore_WithAccountMismatch() {
        Id productId = getFakeId(Product2.SObjectType);
        String accPrefix = Account.SObjectType.getDescribe().getKeyPrefix();
        Id accountId1 = Id.valueOf(accPrefix + '0'.repeat(12));
        Id accountId2 = Id.valueOf(accPrefix + '0'.repeat(11) + '1');
        
        Margin__c margin = new Margin__c();
        margin.Product__c = productId;
        margin.Account__c = accountId1;
        
        Test.startTest();
        Integer score = ScoringService.calculateMarginScore(
            margin,
            productId,
            null,
            accountId2,
            null,
            null,
            null,
            null
        );
        Test.stopTest();
        
        System.assertEquals(-1, score, 'Account mismatch should return -1');
    }
    
    @IsTest
    static void testCalculateMarginScore_WithGroupAccountMatch() {
        Id groupAccountId = getFakeId(Group_Account__c.SObjectType);
        
        Margin__c margin = new Margin__c();
        margin.Product__c = null;
        margin.Account__c = null;
        margin.Group_Account__c = groupAccountId;
        
        Test.startTest();
        Integer score = ScoringService.calculateMarginScore(
            margin,
            null,
            null,
            null,
            groupAccountId,
            null,
            null,
            null
        );
        Test.stopTest();
        
        System.assertEquals(40, score, 'Group account match should score 40');
    }
    
    @IsTest
    static void testCalculateMarginScore_WithCityLocation() {
        Id productId = getFakeId(Product2.SObjectType);
        Id accountId = getFakeId(Account.SObjectType);
        Id cityId = getFakeId(City__c.SObjectType);
        
        Margin__c margin = new Margin__c();
        margin.Product__c = productId;
        margin.Account__c = accountId;
        margin.City__c = cityId;
        
        Test.startTest();
        Integer score = ScoringService.calculateMarginScore(
            margin,
            productId,
            null,
            accountId,
            null,
            cityId,
            null,
            null
        );
        Test.stopTest();
        
        System.assertEquals(190, score, 'Product (100) + Account (60) + City (30) should score 190');
    }
    
    @IsTest
    static void testCalculateMarginScore_WithStateLocation() {
        Id productId = getFakeId(Product2.SObjectType);
        Id accountId = getFakeId(Account.SObjectType);
        Id stateId = getFakeId(State__c.SObjectType);
        
        Margin__c margin = new Margin__c();
        margin.Product__c = productId;
        margin.Account__c = accountId;
        margin.State__c = stateId;
        
        Test.startTest();
        Integer score = ScoringService.calculateMarginScore(
            margin,
            productId,
            null,
            accountId,
            null,
            null,
            stateId,
            null
        );
        Test.stopTest();
        
        System.assertEquals(180, score, 'Product (100) + Account (60) + State (20) should score 180');
    }
    
    @IsTest
    static void testCalculateMarginScore_WithCountryLocation() {
        Id productId = getFakeId(Product2.SObjectType);
        Id accountId = getFakeId(Account.SObjectType);
        Id countryId = getFakeId(Country__c.SObjectType);
        
        Margin__c margin = new Margin__c();
        margin.Product__c = productId;
        margin.Account__c = accountId;
        margin.Country__c = countryId;
        
        Test.startTest();
        Integer score = ScoringService.calculateMarginScore(
            margin,
            productId,
            null,
            accountId,
            null,
            null,
            null,
            countryId
        );
        Test.stopTest();
        
        System.assertEquals(170, score, 'Product (100) + Account (60) + Country (10) should score 170');
    }
    
    // ========================================
    // LOCATION HIERARCHY PREFERENCE TESTS
    // ========================================
    
    @IsTest
    static void testCalculateFreightScore_CityPreferredOverState() {
        Id productId = getFakeId(Product2.SObjectType);
        Id dcId = getFakeId(Distribution_Center__c.SObjectType);
        Id cityId = getFakeId(City__c.SObjectType);
        Id stateId = getFakeId(State__c.SObjectType);
        
        Freight__c freight = new Freight__c();
        freight.Product__c = productId;
        freight.Distribution_Center__c = dcId;
        freight.City__c = cityId;
        freight.State__c = stateId;
        
        Test.startTest();
        Integer score = ScoringService.calculateFreightScore(
            freight,
            productId,
            null,
            dcId,
            cityId,
            stateId,
            null
        );
        Test.stopTest();
        
        System.assertEquals(130, score, 'Should prefer City (30) over State (20)');
    }
    
    @IsTest
    static void testCalculateMarginScore_CityPreferredOverState() {
        Id productId = getFakeId(Product2.SObjectType);
        Id accountId = getFakeId(Account.SObjectType);
        Id cityId = getFakeId(City__c.SObjectType);
        Id stateId = getFakeId(State__c.SObjectType);
        
        Margin__c margin = new Margin__c();
        margin.Product__c = productId;
        margin.Account__c = accountId;
        margin.City__c = cityId;
        margin.State__c = stateId;
        
        Test.startTest();
        Integer score = ScoringService.calculateMarginScore(
            margin,
            productId,
            null,
            accountId,
            null,
            cityId,
            stateId,
            null
        );
        Test.stopTest();
        
        System.assertEquals(190, score, 'Should prefer City (30) over State (20)');
    }
}