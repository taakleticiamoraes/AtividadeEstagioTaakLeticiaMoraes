public class DevUserTriggerHandler {
  public static void run(
    List<DevUser__c> newList,
    Map<Id, DevUser__c> oldMap,
    Boolean isInsert,
    Boolean isUpdate
  ) {
    Set<Id> devUserIds = DevUserService.getUsersToSync(
      newList,
      oldMap,
      isInsert,
      isUpdate
    );

    if (!devUserIds.isEmpty()) {
      System.enqueueJob(new DevUserGithubQueueable(devUserIds));
    }
  }
}
