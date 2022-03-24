/**
 * @description       : Controller for availableConfigs LWC
 * @author            : girish
 * @group             :
 * @last modified on  : 24/03/2022
 * @last modified by  : girish
 **/
public with sharing class AvailableConfigsController {
  /**
   * @description method to return all configs from ConfigService
   * @author girish | 24/03/2022
   * @return List<Config__c>
   **/
  @AuraEnabled(cacheable=true)
  public static List<Config__c> getAllConfigs() {
    try {
      return ConfigService.getConfigs();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description method to add Case configs
   * @author gshinde@paypal.com | 25/03/2022
   * @param caseId
   * @param configs
   * @return Object
   **/
  @AuraEnabled
  public static Object addConfigsToCase(Id caseId, List<Config__c> configs) {
    //validation
    if (String.isBlank(caseId) || configs == null) {
      throw new AuraHandledException(
        'Case Id or selected configs cannot be empty or null'
      );
    }

    try {
      // serialize and deserialize to convert SaveResult into object for LWC
      return (Object) JSON.deserializeUntyped(
        JSON.serializePretty(
          CaseConfigService.insertCaseConfigs(caseId, configs)
        )
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
