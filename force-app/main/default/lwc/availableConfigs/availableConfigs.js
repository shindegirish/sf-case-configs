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

export default class AvailableConfigs extends LightningElement {
  @api recordId; // to get case id

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

  async handleConfigAdd() {
    const selectedConfigs = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();

    if (selectedConfigs && selectedConfigs.length > 0) {
      const payload = {
        caseId: this.recordId,
        configs: [...selectedConfigs]
      };
      const response = await addConfigsToCase(payload);
      this.processResponse(response);
    }
  }

  processResponse(response) {
    if (!response) {
      throw new Error("response is undefined");
    }
    const successRecordsCount = response.filter(
      (config) => config.success
    ).length;

    const errRecrods = response.filter((config) => !config.success);

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
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(event);
  }
}
