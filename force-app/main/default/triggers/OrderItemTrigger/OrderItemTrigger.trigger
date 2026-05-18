trigger OrderItemTrigger on OrderItem(
  before insert,
  before update,
  after insert,
  after update,
  after delete,
  after undelete
) {
  if (Trigger.isBefore) {
    OrderItemTriggerHandler.run(Trigger.new, Trigger.oldMap);
  }

  if (Trigger.isAfter) {
    OrderItemTriggerHandler.handleAfter(Trigger.new, Trigger.oldMap);
  }
}
