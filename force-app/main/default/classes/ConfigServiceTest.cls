@isTest
public class ConfigServiceTest {
  @TestSetup
  static void setup() {
    TestFactory.makeData();
  }

  @IsTest
  static void getConfigsTest() {
    Test.startTest();
    List<Config__c> configList = ConfigService.getConfigs();
    Test.stopTest();
    System.assert(!configList.isEmpty());
  }
}
