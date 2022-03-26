/**
 * @description       : Controller for caseConfigs LWC
 * @author            : girish
 * @group             :
 * @last modified on  : 24/03/2022
 * @last modified by  : girish
 **/
public with sharing class CaseConfigsController {
  /**
   * @description returns all the config records related to particular case
   * @author girish | 24/03/2022
   * @param caseId
   * @return List<Case_Config__c>
   **/
  @AuraEnabled(cacheable=true)
  public static List<Case_Config__c> getCaseConfigs(Id caseId) {
    if (String.isBlank(caseId)) {
      throw new AuraHandledException('Case Id cannot be null or blank');
    }

    try {
      return CaseConfigService.getCaseConfigs(caseId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description closed the case and sends the configs to external service
   * @author girish | 25/03/2022
   * @param caseId
   * @return List<Case_Config__c>
   **/
  @AuraEnabled
  public static Boolean sendCaseConfigs(Id caseId) {
    Boolean isSuccess = false;
    if (String.isBlank(caseId)) {
      throw new AuraHandledException('Case Id cannot be null or blank');
    }

    try {
      List<Case> closedCases = CaseConfigService.closeCases(
        new List<Id>{ caseId }
      );

      if (!closedCases.isEmpty()) {
        System.enqueueJob(new CaseConfigQueueable(closedCases.get(0)));
        isSuccess = true;
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    return isSuccess;
  }
}
