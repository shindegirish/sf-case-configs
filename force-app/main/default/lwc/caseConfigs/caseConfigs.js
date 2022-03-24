/**
 * @description       : a. Displays added Config records in a 3-column list: Label, Type and Amount.
												b. When a user adds new Config records, new records appear in this list without
												having to refresh the page.
 * @last modified on  : 24/03/2022
**/
import { api, LightningElement, track, wire } from "lwc";
import getCaseConfigs from "@salesforce/apex/CaseConfigsController.getCaseConfigs";
export default class CaseConfigs extends LightningElement {
  @api recordId;

  columns = [
    { label: "Label", fieldName: "label", hideDefaultActions: true },
    { label: "Type", fieldName: "type", hideDefaultActions: true },
    {
      label: "Amount",
      fieldName: "amount",
      type: "number",
      hideDefaultActions: true
    }
  ];

  @track data = [];

  @wire(getCaseConfigs, { caseId: "$recordId" })
  wiredCaseConfigs({ data, error }) {
    if (error) {
      this.error = "Unknown error";
      if (Array.isArray(error.body)) {
        this.error = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        this.error = error.body.message;
      }
      return;
    }
    this.setData(data);
  }

  setData(rawData = []) {
    if (!rawData) {
      this.data = [];
      return;
    }
    this.data = rawData.map((config) => {
      const { Id, Label__c, Type__c, Amount__c } = config;
      return {
        id: Id,
        label: Label__c,
        type: Type__c,
        amount: Amount__c
      };
    });
  }
}
