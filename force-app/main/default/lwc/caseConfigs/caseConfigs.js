/**
 * @description       : a. Displays added Config records in a 3-column list: Label, Type and Amount.
												b. When a user adds new Config records, new records appear in this list without
												having to refresh the page.
 * @last modified on  : 24/03/2022
**/
import { api, LightningElement, track, wire } from "lwc";
import getCaseConfigs from "@salesforce/apex/CaseConfigsController.getCaseConfigs";
export default class CaseConfigs extends LightningElement {
  // public props
  @api recordId;

  //reactive props
  columns = [
    { label: "Label", fieldName: "Label__c", hideDefaultActions: true },
    { label: "Type", fieldName: "Type__c", hideDefaultActions: true },
    {
      label: "Amount",
      fieldName: "Amount__c",
      type: "number",
      hideDefaultActions: true
    }
  ];

  @track data = [];

  //wires
  @wire(getCaseConfigs, { caseId: "$recordId" })
  wiredCaseConfigs({ data, error }) {
    // to do - handle errors
    if (error) {
      this.error = "Unknown error";
      if (Array.isArray(error.body)) {
        this.error = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        this.error = error.body.message;
      }
      return;
    }
    this.data = data;
  }
}
