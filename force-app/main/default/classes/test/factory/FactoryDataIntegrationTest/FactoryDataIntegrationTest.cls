@IsTest
public with sharing class FactoryDataIntegrationTest {
  @TestSetup
  public static void makeData() {
    // Minimal test setup
  }

  @IsTest
  public static void testPlaceholder() {
    System.assert(true, 'Placeholder test');
  }
}
