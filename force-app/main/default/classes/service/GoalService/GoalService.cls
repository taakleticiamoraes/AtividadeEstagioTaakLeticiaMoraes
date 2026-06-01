public class GoalService {
  public static void processGoals(List<Goal__c> goals) {
    Set<Id> goalIds = new Set<Id>();

    for (Goal__c g : goals) {
      goalIds.add(g.Id);
    }

    List<GoalItem__c> items = [
      SELECT
        Id,
        Goal__c,
        GoalValue__c,
        RealizedValue__c,
        GoalCommissionPercent__c,
        AchievedPercent__c
      FROM GoalItem__c
      WHERE Goal__c IN :goalIds
    ];
    for (GoalItem__c item : items) {
      Decimal realized = item.RealizedValue__c;

      if (realized >= item.GoalValue__c) {
        item.AchievedPercent__c = item.GoalCommissionPercent__c;
      } else {
        item.AchievedPercent__c = 0;
      }
    }

    if (!items.isEmpty()) {
      update items;
    }
  }
}
