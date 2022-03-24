/**
 * @description       : Controller for availableConfigs LWC
 * @author            : girish
 * @group             :
 * @last modified on  : 24/03/2022
 * @last modified by  : girish
 **/
public with sharing class AvailableConfigsController {
  /**
   * @description returns all the config records related to particular case
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
}
