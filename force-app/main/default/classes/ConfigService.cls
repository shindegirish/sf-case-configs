/**
 * @description       : This class serves as service layer for Config__c object
 * @author            : girish
 * @group             :
 * @last modified on  : 24/03/2022
 * @last modified by  : girish
 **/
public with sharing class ConfigService {
  public static List<Config__c> getConfigs() {
    // the access can also be checked using Schema.sObjectType.Config__c.isAccessible()
    return [
      SELECT Id, Label__c, Type__c, Amount__c
      FROM Config__c
      WITH SECURITY_ENFORCED
      LIMIT 50000
    ];
  }
}