/**
 * @description       : a. Displays added Config records in a 3-column list: Label, Type and Amount.
												b. When a user adds new Config records, new records appear in this list without
												having to refresh the page.
 * @last modified on  : 24/03/2022
**/
import { api, LightningElement, track, wire } from "lwc";
import getCaseConfigs from "@salesforce/apex/CaseConfigsController.getCaseConfigs";
import sendCaseConfigs from "@salesforce/apex/CaseConfigsController.sendCaseConfigs";
import {
  MessageContext,
  subscribe,
  unsubscribe
} from "lightning/messageService";
import notify from "@salesforce/messageChannel/caseConfigNotification__c";
import { refreshApex } from "@salesforce/apex";
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
  subscription;
  cachedData;

  //wires
  @wire(MessageContext)
  messageContext;

  @wire(getCaseConfigs, { caseId: "$recordId" })
  wiredCaseConfigs(cachedData) {
    this.processWiredData(cachedData);
  }

  processWiredData(cachedData) {
    this.cachedData = cachedData;
    const { data, error } = this.cachedData;
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

  //event handlers
  handleSendClick() {
    sendCaseConfigs({ caseId: this.recordId });
  }

  async handleNotification() {
    refreshApex(this.cachedData);
  }

  //lifecycle hooks
  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(this.messageContext, notify, () =>
        this.handleNotification()
      );
    }
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }
}
