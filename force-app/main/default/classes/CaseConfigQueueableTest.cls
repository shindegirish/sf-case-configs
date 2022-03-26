@isTest
class CaseConfigQueueableTest {
  @TestSetup
  static void makeData() {
    TestFactory.makeData();
  }

  @IsTest
  static void queueableTest() {
    Test.setMock(HttpCalloutMock.class, new RequestMock());
    Case caseDetails = [
      SELECT
        Id,
        Status,
        (SELECT Label__c, Type__c, Amount__c FROM Case_Configs__r)
      FROM Case
      LIMIT 1
    ];
    Test.startTest();
    System.enqueueJob(new CaseConfigQueueable(caseDetails));
    Test.stopTest();
  }

  @IsTest
  static void queueableNegativeTest() {
    Case caseDetails = [
      SELECT
        Id,
        Status,
        (SELECT Label__c, Type__c, Amount__c FROM Case_Configs__r)
      FROM Case
      LIMIT 1
    ];

    try {
      Test.startTest();
      System.enqueueJob(new CaseConfigQueueable(caseDetails));
      Test.stopTest();
    } catch (Exception e) {
      System.assertEquals('System.AsyncException', e.getTypeName());
    }
  }
}
