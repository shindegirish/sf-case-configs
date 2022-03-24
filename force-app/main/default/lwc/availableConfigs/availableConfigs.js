/**
 * @description       : a. Displays all Config records in a 3-column list: Label, Type and Amount.
                        b. User can select multiple records and after pressing the “Add” button they will be
                        added to the Case Configs list (also new Case Config records are saved to the
                        database).
                        c. If a Config record has already been added to the Case Configs list it cannot be
                        added a second time.
 * @author            : girish
 * @group             : 
 * @last modified on  : 24/03/2022
 * @last modified by  : girish
**/
import { LightningElement, track, wire } from "lwc";
import getAllConfigs from "@salesforce/apex/AvailableConfigsController.getAllConfigs";

export default class AvailableConfigs extends LightningElement {
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

  @wire(getAllConfigs)
  wiredConfigs({ data, error }) {
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
