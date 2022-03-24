public with sharing class ConfigService {
  public static List<Config__c> getConfigs() {
    return [
      SELECT Id, Label__c, Type__c, Amount__c
      FROM Config__c
      WITH SECURITY_ENFORCED
      LIMIT 50000
    ];
  }
}
