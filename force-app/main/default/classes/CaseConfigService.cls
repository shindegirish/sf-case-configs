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
}
