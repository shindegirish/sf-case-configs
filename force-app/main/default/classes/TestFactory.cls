@isTest
public class TestFactory {
  public static void makeData() {
    Case cs = new Case();
    cs.Subject = 'Test Subject';
    insert cs;

    List<Case_Config__c> csConfigList = new List<Case_Config__c>();
    for (Integer i = 1; i < 3; i++) {
      Case_Config__c csConfig = new Case_Config__c();
      csConfig.Label__c = 'Label ' + i;
      csConfig.Type__c = 'Type ' + i;
      csConfig.Amount__c = 100 * i;
      csConfig.Case__c = cs.Id;
      csConfigList.add(csConfig);
    }

    insert csConfigList;

    List<Config__c> cfgList = new List<Config__c>();

    for (Integer i = 1; i < 6; i++) {
      Config__c config = new Config__c();
      config.Label__c = 'Label ' + i;
      config.Type__c = 'Type ' + i;
      config.Amount__c = 100 * i;
      cfgList.add(config);
    }
    insert cfgList;
  }
}
