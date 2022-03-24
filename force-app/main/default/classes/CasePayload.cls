public class CasePayload {
  public String caseId;
  public String status;
  public List<Case_Config__c> caseConfigs;

  public CasePayload() {
    this.caseConfigs = new List<Case_Config__c>();
  }
}