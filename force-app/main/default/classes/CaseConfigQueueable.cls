public with sharing class CaseConfigQueueable implements Queueable, Database.AllowsCallouts {
  Case caseDetails;
  public CaseConfigQueueable(Case cs) {
    this.caseDetails = cs;
  }

  public void execute(QueueableContext context) {
    CaseConfigService.sendConfigInformation(caseDetails);
  }
}