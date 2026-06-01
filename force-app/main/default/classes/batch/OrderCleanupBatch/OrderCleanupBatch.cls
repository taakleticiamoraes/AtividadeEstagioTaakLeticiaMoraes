public class OrderCleanupBatch implements Database.Batchable<SObject> {
  private Integer numberOfMonths;

  public OrderCleanupBatch() {
    this.numberOfMonths = getMonthsParameter();
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    Date limitDate = Date.today().addMonths(-numberOfMonths);

    return Database.getQueryLocator(
      [
        SELECT Id
        FROM Order
        WHERE CreatedDate < :limitDate
      ]
    );
  }

  public void execute(Database.BatchableContext bc, List<Order> scope) {
    Set<Id> orderIds = new Set<Id>();

    for (Order orderRecord : scope) {
      orderIds.add(orderRecord.Id);
    }

    // Buscar anexos antigos (Attachment)
    List<Attachment> attachmentsToDelete = [
      SELECT Id
      FROM Attachment
      WHERE ParentId IN :orderIds
    ];

    if (!attachmentsToDelete.isEmpty()) {
      delete attachmentsToDelete;
    }

    delete scope;
  }

  public void finish(Database.BatchableContext bc) {
    // nenhuma ação
  }

  private Integer getMonthsParameter() {
    DevParameters__mdt parameter = DevParameters__mdt.getInstance(
      'MaxNumberMonthsOrder'
    );

    if (parameter == null || String.isBlank(parameter.Value__c)) {
      return 6;
    }

    return Integer.valueOf(parameter.Value__c);
  }
}
