public class GoalBatch implements Database.Batchable<SObject> {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    Integer currentYear = Date.today().year();

    return Database.getQueryLocator(
      [
        SELECT Id, Seller__c, Year__c
        FROM Goal__c
        WHERE Year__c = :currentYear
      ]
    );
  }

  public void execute(Database.BatchableContext bc, List<Goal__c> scope) {
    GoalService.processGoals(scope);
  }

  public void finish(Database.BatchableContext bc) {
    System.debug('Batch finalizado');
  }
}
