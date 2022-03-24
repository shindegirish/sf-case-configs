/**
 * @description       : This class serves as service layer for Case_Config__c object
 * @author            : girish
 * @group             :
 * @last modified on  : 24/03/2022
 * @last modified by  : girish
 **/
public with sharing class CaseConfigService {
  public static List<Case_Config__c> getCaseConfigs(Id caseId) {
    return [
      SELECT Id, Label__c, Type__c, Amount__c
      FROM Case_Config__c
      WHERE Case__c = :caseId
      WITH SECURITY_ENFORCED
      LIMIT 50000
    ];
  }

  public static List<Database.SaveResult> insertCaseConfigs(
    Id caseId,
    List<Config__c> configs
  ) {
    List<Database.SaveResult> results = new List<Database.SaveResult>();
    List<Case_Config__c> caseConfigList = new List<Case_Config__c>();
    for (Config__c conf : configs) {
      Case_Config__c caseConfig = new Case_Config__c();
      caseConfig.Case__c = caseId;
      caseConfig.Label__c = conf.Label__c;
      caseConfig.Type__c = conf.Type__c;
      caseConfig.Amount__c = conf.Amount__c;
      caseConfigList.add(caseConfig);
    }

    if (!caseConfigList.isEmpty()) {
      results = Database.insert(caseConfigList, false);
    }
    return results;
  }
}
