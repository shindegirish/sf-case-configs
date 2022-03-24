import { LightningElement, track, wire } from "lwc";
import getAllConfigs from "@salesforce/apex/AvailableConfigsController.getAllConfigs";

export default class AvailableConfigs extends LightningElement {
  columns = [
    { label: "Label", fieldName: "label" },
    { label: "Type", fieldName: "type" },
    { label: "Amount", fieldName: "amount", type: "number" }
  ];

  @track data = [];

  @wire(getAllConfigs)
  wireConfigs({ data, error }) {
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
