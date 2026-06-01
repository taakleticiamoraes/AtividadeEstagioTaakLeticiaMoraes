trigger DevUserTrigger on DevUser__c(after insert, after update) {
  DevUserTriggerHandler.run(
    Trigger.new,
    Trigger.oldMap,
    Trigger.isInsert,
    Trigger.isUpdate
  );
}
