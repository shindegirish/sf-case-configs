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
import { api, LightningElement, track, wire } from "lwc";
import getAllConfigs from "@salesforce/apex/AvailableConfigsController.getAllConfigs";
import addConfigsToCase from "@salesforce/apex/AvailableConfigsController.addConfigsToCase";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { MessageContext, publish } from "lightning/messageService";
import notify from "@salesforce/messageChannel/caseConfigNotification__c";

export default class AvailableConfigs extends LightningElement {
  //public properties
  @api recordId; // to get case id

  //reactive properties
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

  //wired calls
  @wire(MessageContext)
  messageContext;

  @wire(getAllConfigs)
  wiredConfigs({ data, error }) {
    //to do process errors
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

  // event handlers
  async handleConfigAdd() {
    //get selected rows
    const selectedConfigs = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();

    //validation
    if (selectedConfigs.length === 0) {
      this.showToast("Please select at least one Config", undefined, "error");
      return;
    }

    //apex call to insert new case configs
    const payload = {
      caseId: this.recordId,
      configs: [...selectedConfigs]
    };
    const response = await addConfigsToCase(payload);
    this.processResponse(response);
  }

  // method to process server response
  processResponse(response) {
    if (!response) {
      throw new Error("response is undefined");
    }

    //get success record count
    const successRecordsCount = response.filter(
      (config) => config.success
    ).length;

    //get error records
    const errRecrods = response.filter((config) => !config.success);

    // show toast for successful and failed records
    if (successRecordsCount > 0) {
      this.showToast(
        `Successfully added ${successRecordsCount} configs to this case.`,
        undefined,
        "success"
      );
    }

    if (errRecrods.length > 0) {
      errRecrods
        .flatMap((e) => e.errors)
        .forEach((err) => {
          const { statusCode, message } = err;
          // this can be made more user friendly
          this.showToast(statusCode, message, "error");
        });
    }
    publish(this.messageContext, notify, {});
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