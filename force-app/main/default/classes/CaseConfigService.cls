/**
 * @description       : This class serves as service layer for Case_Config__c object
 * @author            : girish
 * @group             :
 * @last modified on  : 24/03/2022
 * @last modified by  : girish
 **/
public with sharing class CaseConfigService {
  /**
   * @description
   * @author girish | 26/03/2022
   * @param caseId
   * @return List<Case_Config__c>
   **/
  public static List<Case_Config__c> getCaseConfigs(Id caseId) {
    try {
      return [
        SELECT Id, Label__c, Type__c, Amount__c
        FROM Case_Config__c
        WHERE Case__c = :caseId
        WITH SECURITY_ENFORCED
        LIMIT 50000
      ];
    } catch (Exception e) {
      //log exception in db
      throw new HandledException(e);
    }
  }

  /**
   * @description
   * @author girish | 26/03/2022
   * @param caseId
   * @param configs
   * @return List<Database.SaveResult>
   **/
  public static List<Database.SaveResult> insertCaseConfigs(
    Id caseId,
    List<Config__c> configs
  ) {
    List<Database.SaveResult> results = new List<Database.SaveResult>();
    try {
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
    } catch (Exception e) {
      //log exception in db
      throw new HandledException(e);
    }

    return results;
  }

  /**
   * @description
   * @author girish | 26/03/2022
   * @param caseIds
   * @return List<Case>
   **/
  public static List<Case> closeCases(List<Id> caseIds) {
    List<Case> casesToUpdate = new List<Case>();
    try {
      // get the case and related configs
      List<Case> caseList = [
        SELECT
          Id,
          Status,
          (SELECT Label__c, Type__c, Amount__c FROM Case_Configs__r)
        FROM Case
        WHERE Id IN :caseIds
        LIMIT 50000
      ];

      if (caseList.isEmpty()) {
        return caseList;
      }

      //update status field
      for (Case cs : caseList) {
        if (!cs.Status.equalsIgnoreCase('Closed')) {
          cs.Status = 'Closed';
          casesToUpdate.add(cs);
        }
      }

      if (!casesToUpdate.isEmpty()) {
        update casesToUpdate;
      }
    } catch (Exception e) {
      //log exception in db
      throw new HandledException(e);
    }

    return casesToUpdate;
  }

  /**
   * @description
   * @author girish | 26/03/2022
   * @param caseDetails
   **/
  public static void sendConfigInformation(Case caseDetails) {
    try {
      //create payload
      CasePayload payload = new CasePayload();
      payload.caseId = caseDetails.Id;
      payload.status = caseDetails.Status;
      payload.caseConfigs = getMashedCaseConfigs(caseDetails.Case_Configs__r);

      //create request
      HttpRequest req = new HttpRequest();
      req.setEndpoint('callout:Clark_External_Service');
      req.setMethod('POST');
      req.setHeader('Content-Type', 'application/json');
      req.setBody(JSON.serialize(payload));
      Http http = new Http();
      HTTPResponse res = http.send(req);

      // to do handle errors
      if (res.getStatusCode() != 200) {
        // error handling here
        // insert platform event for logging errors
        // platform event trigger would create record in log object
        // if we need to inform the lwc about success or failure, then we will have to create a plaform event and fire it
        // then from lwc subscribe to the PE using empAPI and show err to the user
      }
    } catch (Exception e) {
      //log exception in db
      throw new HandledException(e);
    }
  }

  public static List<CasePayload.CaseConfig> getMashedCaseConfigs(
    List<Case_Config__c> configs
  ) {
    List<CasePayload.CaseConfig> caseConfigs = new List<CasePayload.CaseConfig>();
    //add null and empty checks
    //add try catch
    for (Case_Config__c conf : configs) {
      caseConfigs.add(
        new CasePayload.CaseConfig(conf.Label__c, conf.Type__c, conf.Amount__c)
      );
    }
    return caseConfigs;
  }
}
