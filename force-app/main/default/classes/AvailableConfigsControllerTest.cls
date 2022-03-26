@isTest
class AvailableConfigsControllerTest {
  @TestSetup
  static void makeData() {
    TestFactory.makeData();
  }

  @IsTest
  static void getAllConfigsTest() {
    Test.startTest();
    List<Config__c> configList = AvailableConfigsController.getAllConfigs();
    Test.stopTest();
    System.assert(!configList.isEmpty());
  }

  @IsTest
  static void addConfigsToCaseTest() {
    Id caseId = [SELECT Id FROM Case LIMIT 1]?.Id;
    List<Config__c> configs = [
      SELECT Label__c, Type__c, Amount__c
      FROM Config__c
    ];
    Test.startTest();
    Object results = AvailableConfigsController.addConfigsToCase(
      caseId,
      configs
    );
    Test.stopTest();
    System.assert(results != null);
  }

  @IsTest
  static void addConfigsToCaseNegativeTest1() {
    Test.startTest();
    try {
      Object obj = AvailableConfigsController.addConfigsToCase(null, null);
    } catch (Exception e) {
      System.assertEquals('Script-thrown exception', e.getMessage());
    }
    Test.stopTest();
  }
  @IsTest
  static void addConfigsToCaseNegativeTest2() {
    Id caseId = [SELECT Id FROM Case LIMIT 1]?.Id;
    List<Config__c> configs = [SELECT Label__c FROM Config__c];
    Test.startTest();
    try {
      Object obj = AvailableConfigsController.addConfigsToCase(caseId, configs);
    } catch (Exception e) {
      System.assertEquals('Script-thrown exception', e.getMessage());
    }
    Test.stopTest();
  }
}
