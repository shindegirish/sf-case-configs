public with sharing class AvailableConfigsController {
  @AuraEnabled(cacheable=true)
  public static List<Config__c> getAllConfigs() {
    try {
      return ConfigService.getConfigs();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
