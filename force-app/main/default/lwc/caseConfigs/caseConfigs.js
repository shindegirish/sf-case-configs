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
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class CaseConfigs extends LightningElement {
  // public props
  @api recordId;

  //reactive props
  columns = [
    {
      label: "Label",
      fieldName: "Label__c",
      hideDefaultActions: true,
      sortable: true
    },
    {
      label: "Type",
      fieldName: "Type__c",
      hideDefaultActions: true,
      sortable: true
    },
    {
      label: "Amount",
      fieldName: "Amount__c",
      type: "number",
      hideDefaultActions: true,
      sortable: true
    }
  ];

  @track data = [];
  subscription;
  cachedData;
  defaultSortDirection = "asc";
  sortDirection = "asc";
  sortedBy;

  isLoading;

  get showSendButton() {
    return this.data && this.data.length > 0;
  }

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
    // to do - handle errors, add spinner
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
  async handleSendClick() {
    this.isLoading = true;
    const isRequestSuccessful = await sendCaseConfigs({
      caseId: this.recordId
    });
    const title = isRequestSuccessful
      ? "Case configs sent successfully!"
      : "Opps! Something went wrong";
    const type = isRequestSuccessful ? "success" : "error";
    this.showToast(title, undefined, type);
    this.isLoading = false;
  }

  handleSort(event) {
    console.log(JSON.stringify(event.detail));
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.data];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.data = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  sortBy(field, reverse, primer) {
    const key = primer
      ? function (x) {
          return primer(x[field]);
        }
      : function (x) {
          return x[field];
        };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
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

  //generic method to fire show toast event
  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(event);
  }
}
