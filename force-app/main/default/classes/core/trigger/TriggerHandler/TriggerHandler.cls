public abstract class TriggerHandler {
    
    @TestVisible
    private static Boolean testIsBefore;
    @TestVisible
    private static Boolean testIsAfter;
    @TestVisible
    private static Boolean testIsInsert;
    @TestVisible
    private static Boolean testIsUpdate;
    @TestVisible
    private static Boolean testIsDelete;
    @TestVisible
    private static Boolean testIsUndelete;
    
    @TestVisible
    static void setTestContext(
        Boolean isBefore,
    Boolean isAfter,
    Boolean isInsert,
    Boolean isUpdate,
    Boolean isDelete,
    Boolean isUndelete
    ) {
        testIsBefore = isBefore;
        testIsAfter = isAfter;
        testIsInsert = isInsert;
        testIsUpdate = isUpdate;
        testIsDelete = isDelete;
        testIsUndelete = isUndelete;
    }
    
    @TestVisible
    static void clearTestContext() {
        testIsBefore = null;
        testIsAfter = null;
        testIsInsert = null;
        testIsUpdate = null;
        testIsDelete = null;
        testIsUndelete = null;
    }
    
    public void run() {
        if (Trigger.isExecuting || Test.isRunningTest()) {
            Boolean isBeforeContext = Trigger.isExecuting ? Trigger.isBefore : (testIsBefore == true);
            Boolean isAfterContext = Trigger.isExecuting ? Trigger.isAfter : (testIsAfter == true);
            Boolean isInsertContext = Trigger.isExecuting ? Trigger.isInsert : (testIsInsert == true);
            Boolean isUpdateContext = Trigger.isExecuting ? Trigger.isUpdate : (testIsUpdate == true);
            Boolean isDeleteContext = Trigger.isExecuting ? Trigger.isDelete : (testIsDelete == true);
            Boolean isUndeleteContext = Trigger.isExecuting ? Trigger.isUndelete : (testIsUndelete == true);
            
            if (isBeforeContext) {
                if (isInsertContext) {
                    beforeInsert();
                }
                if (isUpdateContext) {
                    beforeUpdate();
                }
                if (isDeleteContext) {
                    beforeDelete();
                }
            }
            
            if (isAfterContext) {
                if (isInsertContext) {
                    afterInsert();
                }
                if (isUpdateContext) {
                    afterUpdate();
                }
                if (isDeleteContext) {
                    afterDelete();
                }
                if (isUndeleteContext) {
                    afterUndelete();
                }
            }
        }
    }
    
    // BEFORE
    protected virtual void beforeInsert() {}
    protected virtual void beforeUpdate() {}
    protected virtual void beforeDelete() {}
    
    // AFTER
    protected virtual void afterInsert() {}
    protected virtual void afterUpdate() {}
    protected virtual void afterDelete() {}
    protected virtual void afterUndelete() {}
}