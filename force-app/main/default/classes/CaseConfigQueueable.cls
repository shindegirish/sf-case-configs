public with sharing class CaseConfigQueueable implements Queueable, Database.AllowsCallouts {
  Case caseDetails;
  public CaseConfigQueueable(Case cs) {
    this.caseDetails = cs;
  }

  public void execute(QueueableContext context) {
    try {
      CaseConfigService.sendConfigInformation(caseDetails);
    } catch (Exception e) {
      // log in db and fire PE to let UI know about this fire
      throw new AsyncException(e);
    }
  }
}
