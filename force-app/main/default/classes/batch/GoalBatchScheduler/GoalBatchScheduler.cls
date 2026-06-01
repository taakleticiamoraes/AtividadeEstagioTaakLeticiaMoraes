public class GoalBatchScheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new GoalBatch(), 200);
  }
}
