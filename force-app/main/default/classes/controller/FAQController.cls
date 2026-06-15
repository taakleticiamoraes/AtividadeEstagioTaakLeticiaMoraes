public with sharing class FAQController {
  @AuraEnabled(cacheable=true)
  public static FAQWrapper getFAQs(
    String searchTerm,
    Integer pageNumber,
    Integer pageSize
  ) {
    String key = '%' + (searchTerm != null ? searchTerm.trim() : '') + '%';
    Integer offsetValue = (pageNumber - 1) * pageSize;

    Integer totalRecords = [
      SELECT COUNT()
      FROM FAQ__c
      WHERE Question__c LIKE :key
    ];

    List<FAQ__c> faqList = [
      SELECT Id, Question__c, Answer__c
      FROM FAQ__c
      WHERE Question__c LIKE :key
      ORDER BY CreatedDate DESC
      LIMIT :pageSize
      OFFSET :offsetValue
    ];

    return new FAQWrapper(faqList, totalRecords);
  }

  public class FAQWrapper {
    @AuraEnabled
    public List<FAQ__c> faqList { get; set; }
    @AuraEnabled
    public Integer totalRecords { get; set; }

    public FAQWrapper(List<FAQ__c> faqList, Integer totalRecords) {
      this.faqList = faqList;
      this.totalRecords = totalRecords;
    }
  }
}
