public class DevUserService {
  public static Set<Id> getUsersToSync(
    List<DevUser__c> newList,
    Map<Id, DevUser__c> oldMap,
    Boolean isInsert,
    Boolean isUpdate
  ) {
    Set<Id> ids = new Set<Id>();

    for (DevUser__c dev : newList) {
      if (isInsert && !String.isBlank(dev.Login__c)) {
        ids.add(dev.Id);
        continue;
      }

      if (isUpdate) {
        DevUser__c oldDev = oldMap.get(dev.Id);

        Boolean loginChanged = dev.Login__c != oldDev.Login__c;

        if (loginChanged && !String.isBlank(dev.Login__c)) {
          ids.add(dev.Id);
        }
      }
    }

    return ids;
  }

  public static void updateUsers(List<DevUser__c> updates) {
    if (!updates.isEmpty()) {
      update updates;
    }
  }
}
