public class DevUserGithubQueueable implements Queueable, Database.AllowsCallouts {
  private Set<Id> devUserIds;

  public DevUserGithubQueueable(Set<Id> devUserIds) {
    this.devUserIds = devUserIds;
  }

  public void execute(QueueableContext context) {
    List<DevUser__c> devUsers = [
      SELECT Id, Login__c
      FROM DevUser__c
      WHERE Id IN :devUserIds
    ];

    List<DevUser__c> updates = new List<DevUser__c>();

    for (DevUser__c dev : devUsers) {
      HttpRequest req = new HttpRequest();

      req.setMethod('GET');
      req.setEndpoint('https://api.github.com/users/' + dev.Login__c);

      Http http = new Http();

      HttpResponse res = http.send(req);

      if (res.getStatusCode() == 200) {
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(
          res.getBody()
        );

        updates.add(
          new DevUser__c(
            Id = dev.Id,
            ExternalId__c = Decimal.valueOf(String.valueOf(body.get('id'))),
            Type__c = (String) body.get('type'),
            Bio__c = (String) body.get('bio')
          )
        );
      }
    }

    DevUserService.updateUsers(updates);
  }
}
