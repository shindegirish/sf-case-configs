@isTest
public class CaseConfigsControllerTest {
  @TestSetup
  static void makeData() {
    TestFactory.makeData();
  }

  @IsTest
  static void getCaseConfigsTest() {
    Id caseId = [SELECT Id FROM Case LIMIT 1]?.Id;
    Test.startTest();
    List<Case_Config__c> csConfig = CaseConfigsController.getCaseConfigs(
      caseId
    );
    Test.stopTest();
    System.assert(!csConfig.isEmpty());
  }

  @IsTest
  static void getCaseConfigsNegativeTest() {
    try {
      Test.startTest();
      List<Case_Config__c> csConfig = CaseConfigsController.getCaseConfigs(
        null
      );
      Test.stopTest();
    } catch (Exception e) {
      System.assertEquals('Script-thrown exception', e.getMessage());
    }
  }

  @IsTest
  static void sendCaseConfigsTest() {
    Test.setMock(HttpCalloutMock.class, new RequestMock());
    Id caseId = [SELECT Id FROM Case LIMIT 1]?.Id;
    Test.startTest();
    Boolean requestSent = CaseConfigsController.sendCaseConfigs(caseId);
    Test.stopTest();
    System.assert(requestSent);
  }

  @IsTest
  static void sendCaseConfigsNegativeTest() {
    try {
      Test.startTest();
      Boolean requestSent = CaseConfigsController.sendCaseConfigs(null);
      Test.stopTest();
    } catch (Exception e) {
      System.assertEquals('Script-thrown exception', e.getMessage());
    }
  }

  @IsTest
  static void sendCaseConfigsNegativeTest2() {
    Id caseId = [SELECT Id FROM Case LIMIT 1]?.Id;
    try {
      Test.startTest();
      Boolean requestSent = CaseConfigsController.sendCaseConfigs(caseId);
      Test.stopTest();
    } catch (Exception e) {
      System.assertEquals('System.AsyncException', e.getTypeName());
    }
  }
}
