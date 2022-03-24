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

  public static void sendCaseConfigs(Id caseId) {
    // get the case and related configs
    List<Case> caseList = [
      SELECT
        Id,
        Status,
        (SELECT Label__c, Type__c, Amount__c FROM Case_Configs__r)
      FROM Case
      WHERE Id = :caseId
    ];

    if (caseList.isEmpty()) {
      return;
    }

    Case cs = caseList.get(0);
    cs.Status = 'Closed';
    update cs;
    System.enqueueJob(new CaseConfigQueueable(cs));
  }

  public static void sendConfigInformation(Case caseDetails) {
    //create payload
    CasePayload payload = new CasePayload();
    payload.caseId = caseDetails.Id;
    payload.status = caseDetails.Status;
    payload.caseConfigs = caseDetails.Case_Configs__r; // this would send additionl attribute property as well. if required, that can be cleaned up as well.

    //create request
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:Clark_External_Service');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setBody(JSON.serialize(payload));
    Http http = new Http();
    HTTPResponse res = http.send(req);

    if (res.getStatusCode() != 200) {
      // error handling here
      // insert platform event for logging errors
      // platform event trigger would create record in log object
    }

    // if we need to inform the lwc about success or failure, then we will have to create a plaform event and fire it
    // then from lwc subscribe to the PE using empAPI and show err to the user
  }
}
