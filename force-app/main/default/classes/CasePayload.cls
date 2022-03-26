public class CasePayload {
  public String caseId;
  public String status;
  public List<CaseConfig> caseConfigs;

  public CasePayload() {
    this.caseConfigs = new List<CaseConfig>();
  }

  public class CaseConfig {
    String label;
    String type;
    Decimal amount;

    public CaseConfig(String label, String type, Decimal amount) {
      this.label = label;
      this.type = type;
      this.amount = amount;
    }
  }
}
