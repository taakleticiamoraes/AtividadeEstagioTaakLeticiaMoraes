public class OrderCleanupScheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new OrderCleanupBatch(), 10);
  }
}
