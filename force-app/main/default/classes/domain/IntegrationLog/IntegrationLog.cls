public with sharing class IntegrationLog {
  public static String createLog(
    String integrationName,
    List<String> externalIdList,
    String recordTypeName,
    String payloadIN,
    String payloadOUT,
    String errorMessage,
    String endpoint,
    Integer statusCode,
    Boolean hasAnyErrors,
    Boolean hasDeleted,
    Order relatedOrder
  ) {
    System.debug('');
    Boolean attachmentIN = (payloadIN.length() > 130000);
    Boolean attachmentOUT = (payloadOUT.length() > 130000);
    Datetime datetimeNow = System.now();
    Id recordTypeId = Schema.SObjectType.IntegrationLog__c.getRecordTypeInfosByDeveloperName()
        .containsKey(recordTypeName)
      ? Schema.SObjectType.IntegrationLog__c.getRecordTypeInfosByName()
          .get(recordTypeName)
          .getRecordTypeId()
      : null;

    if (recordTypeId == null)
      System.debug(
        'Failed to get recordTypeId of integration log => ' + recordTypeId
      );

    IntegrationLog__c log = createIntegrationLogRecord(
      integrationName,
      externalIdList,
      recordTypeId,
      recordTypeName,
      attachmentIN,
      attachmentOUT,
      payloadIN,
      payloadOUT,
      errorMessage,
      endpoint,
      hasAnyErrors,
      datetimeNow,
      hasDeleted,
      relatedOrder
    );

    try {
      insert log;

      if (attachmentIN)
        createAttachment(
          log.Id,
          integrationName,
          'IN',
          log.Name,
          String.valueOf(datetimeNow),
          payloadIN
        );
      if (attachmentOUT)
        createAttachment(
          log.Id,
          integrationName,
          'OUT',
          log.Name,
          String.valueOf(datetimeNow),
          payloadOUT
        );
    } catch (Exception error) {
      System.debug(
        'EXCEPTION ON LOG - Please review parameters - ' +
          error.getMessage() +
          ' - ' +
          error.getStackTraceString()
      );
      log.Status__c = 'Error';
      log.ErrorMessage__c = error.getMessage();
    }

    return (String) log.Id;
  }

  public static IntegrationLog__c createIntegrationLogRecord(
    String integrationName,
    List<String> externalIdList,
    Id recordTypeId,
    String recordTypeName,
    Boolean attachmentIN,
    Boolean attachmentOUT,
    String payloadIN,
    String payloadOUT,
    String errorMessage,
    String endpoint,
    Boolean hasAnyErrors,
    Datetime datetimeNow,
    Boolean hasDeleted,
    Order relatedOrder
  ) {
    String externalIdString = String.join(externalIdList, ', ');
    return new IntegrationLog__c(
      Name = integrationName +
        ' ' +
        recordTypeName +
        ' - ' +
        (relatedOrder != null ? relatedOrder.ExternalId__c : 'N/A'),
      Endpoint__c = endpoint,
      ExternalIdList__c = externalIdString.length() > 255
        ? externalIdString.substring(0, 256)
        : externalIdString,
      RecordTypeId = recordTypeId,
      Attachment__c = (attachmentIN || attachmentOUT),
      PayloadIN__c = (attachmentIN ? '' : payloadIN),
      PayloadOUT__c = (attachmentOUT ? '' : payloadOUT),
      ExecutionDate__c = datetimeNow,
      Status__c = (hasAnyErrors ? 'Error' : 'Success'),
      ErrorMessage__c = errorMessage,
      HasDeleted__c = hasDeleted,
      Order__c = (relatedOrder != null ? relatedOrder.Id : null)
    );
  }

  @TestVisible
  private static Id createAttachment(
    String recordId,
    String integrationName,
    String inOrOut,
    String logName,
    String timeAsString,
    String payload
  ) {
    Attachment attachment = new Attachment(
      Name = 'LOG-' +
        integrationName +
        '-' +
        inOrOut +
        '-' +
        timeAsString +
        '.txt',
      Body = Blob.valueOf(payload),
      ParentId = recordId
    );

    insert attachment;

    return attachment.Id;
  }
}
