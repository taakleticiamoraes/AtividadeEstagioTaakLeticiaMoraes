public abstract class TriggerHandler {

    public void run() {

        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                beforeInsert();
            }
            if (Trigger.isUpdate) {
                beforeUpdate();
            }
            if (Trigger.isDelete) {
                beforeDelete();
            }
        }

        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                afterInsert();
            }
            if (Trigger.isUpdate) {
                afterUpdate();
            }
            if (Trigger.isDelete) {
                afterDelete();
            }
            if (Trigger.isUndelete) {
                afterUndelete();
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