@isTest
class CaseConfigServiceTest {
  @TestSetup
  static void setupData() {
    TestFactory.makeData();
  }

  @IsTest
  static void getCaseConfigsTest() {
    Id caseId = [SELECT Id FROM Case LIMIT 1]?.Id;
    Test.startTest();
    List<Case_Config__c> csConfig = CaseConfigService.getCaseConfigs(caseId);
    Test.stopTest();
    System.assert(!csConfig.isEmpty());
  }

  @IsTest
  static void insertCaseConfigsTest() {
    Id caseId = [SELECT Id FROM Case LIMIT 1]?.Id;
    List<Config__c> configs = [
      SELECT Label__c, Type__c, Amount__c
      FROM Config__c
    ];
    Test.startTest();
    List<Database.SaveResult> results = CaseConfigService.insertCaseConfigs(
      caseId,
      configs
    );
    Test.stopTest();
    System.assert(!results.isEmpty());
  }

  @IsTest
  static void closeCasesTest() {
    Id caseId = [SELECT Id FROM Case LIMIT 1]?.Id;
    Test.startTest();
    List<Case> cs = CaseConfigService.closeCases(new List<Id>{ caseId });
    Test.stopTest();
    System.assert(!cs.isEmpty());
    System.assertEquals('Closed', cs.get(0).Status);
  }

  @IsTest
  static void sendConfigInformationTest() {
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
    CaseConfigService.sendConfigInformation(caseDetails);
    Test.stopTest();
  }
}
