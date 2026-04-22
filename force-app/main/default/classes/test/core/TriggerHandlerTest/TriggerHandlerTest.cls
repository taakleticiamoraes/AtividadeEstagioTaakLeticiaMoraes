@IsTest
public class TriggerHandlerTest {
    
    private class TriggerHandlerStub extends TriggerHandler {
        public Integer beforeInsertCount = 0;
        public Integer beforeUpdateCount = 0;
        public Integer beforeDeleteCount = 0;
        public Integer afterInsertCount = 0;
        public Integer afterUpdateCount = 0;
        public Integer afterDeleteCount = 0;
        public Integer afterUndeleteCount = 0;
        
        public void runHandler() {
            run();
        }
        
        public void callAllBaseHooks() {
            super.beforeInsert();
            super.beforeUpdate();
            super.beforeDelete();
            super.afterInsert();
            super.afterUpdate();
            super.afterDelete();
            super.afterUndelete();
        }
        
        public void callAllOverriddenHooks() {
            beforeInsert();
            beforeUpdate();
            beforeDelete();
            afterInsert();
            afterUpdate();
            afterDelete();
            afterUndelete();
        }
        
        protected override void beforeInsert() {
            beforeInsertCount++;
        }
        
        protected override void beforeUpdate() {
            beforeUpdateCount++;
        }
        
        protected override void beforeDelete() {
            beforeDeleteCount++;
        }
        
        protected override void afterInsert() {
            afterInsertCount++;
        }
        
        protected override void afterUpdate() {
            afterUpdateCount++;
        }
        
        protected override void afterDelete() {
            afterDeleteCount++;
        }
        
        protected override void afterUndelete() {
            afterUndeleteCount++;
        }
    }
    
    @IsTest
    static void testRunOutsideTriggerContextDoesNotCallHooks() {
        TriggerHandlerStub handler = new TriggerHandlerStub();
        TriggerHandler.clearTestContext();
        
        Test.startTest();
        handler.runHandler();
        Test.stopTest();
        
        System.assertEquals(0, handler.beforeInsertCount, 'beforeInsert should not execute outside trigger context');
        System.assertEquals(0, handler.beforeUpdateCount, 'beforeUpdate should not execute outside trigger context');
        System.assertEquals(0, handler.beforeDeleteCount, 'beforeDelete should not execute outside trigger context');
        System.assertEquals(0, handler.afterInsertCount, 'afterInsert should not execute outside trigger context');
        System.assertEquals(0, handler.afterUpdateCount, 'afterUpdate should not execute outside trigger context');
        System.assertEquals(0, handler.afterDeleteCount, 'afterDelete should not execute outside trigger context');
        System.assertEquals(0, handler.afterUndeleteCount, 'afterUndelete should not execute outside trigger context');
    }
    
    @IsTest
    static void testOverriddenHooksCanBeExecuted() {
        TriggerHandlerStub handler = new TriggerHandlerStub();
        TriggerHandler.clearTestContext();
        
        Test.startTest();
        handler.callAllOverriddenHooks();
        Test.stopTest();
        
        System.assertEquals(1, handler.beforeInsertCount, 'beforeInsert must increment once');
        System.assertEquals(1, handler.beforeUpdateCount, 'beforeUpdate must increment once');
        System.assertEquals(1, handler.beforeDeleteCount, 'beforeDelete must increment once');
        System.assertEquals(1, handler.afterInsertCount, 'afterInsert must increment once');
        System.assertEquals(1, handler.afterUpdateCount, 'afterUpdate must increment once');
        System.assertEquals(1, handler.afterDeleteCount, 'afterDelete must increment once');
        System.assertEquals(1, handler.afterUndeleteCount, 'afterUndelete must increment once');
    }
    
    @IsTest
    static void testBaseHooksAreNoOpAndDoNotThrow() {
        TriggerHandlerStub handler = new TriggerHandlerStub();
        TriggerHandler.clearTestContext();
        
        Test.startTest();
        handler.callAllBaseHooks();
        Test.stopTest();
        
        System.assert(true, 'Base hook methods should run as no-op without exceptions');
    }
    
    @IsTest
    static void testRunBeforeBranchesWithTestContext() {
        TriggerHandlerStub handler = new TriggerHandlerStub();
        TriggerHandler.setTestContext(true, false, true, true, true, false);
        
        Test.startTest();
        handler.runHandler();
        Test.stopTest();
        
        System.assertEquals(1, handler.beforeInsertCount, 'beforeInsert should execute once');
        System.assertEquals(1, handler.beforeUpdateCount, 'beforeUpdate should execute once');
        System.assertEquals(1, handler.beforeDeleteCount, 'beforeDelete should execute once');
        System.assertEquals(0, handler.afterInsertCount, 'afterInsert should not execute');
        System.assertEquals(0, handler.afterUpdateCount, 'afterUpdate should not execute');
        System.assertEquals(0, handler.afterDeleteCount, 'afterDelete should not execute');
        System.assertEquals(0, handler.afterUndeleteCount, 'afterUndelete should not execute');
        
        TriggerHandler.clearTestContext();
    }
    
    @IsTest
    static void testRunAfterBranchesWithTestContext() {
        TriggerHandlerStub handler = new TriggerHandlerStub();
        TriggerHandler.setTestContext(false, true, true, true, true, true);
        
        Test.startTest();
        handler.runHandler();
        Test.stopTest();
        
        System.assertEquals(0, handler.beforeInsertCount, 'beforeInsert should not execute');
        System.assertEquals(0, handler.beforeUpdateCount, 'beforeUpdate should not execute');
        System.assertEquals(0, handler.beforeDeleteCount, 'beforeDelete should not execute');
        System.assertEquals(1, handler.afterInsertCount, 'afterInsert should execute once');
        System.assertEquals(1, handler.afterUpdateCount, 'afterUpdate should execute once');
        System.assertEquals(1, handler.afterDeleteCount, 'afterDelete should execute once');
        System.assertEquals(1, handler.afterUndeleteCount, 'afterUndelete should execute once');
        
        TriggerHandler.clearTestContext();
    }
    
}