import { LightningElement, api } from "lwc";
import { NotifyFieldUpdates } from "lightning/uiRecordApi";
import runIntegrationFromLWC from "@salesforce/apex/InvocableOrderIntegration.runIntegrationFromLWC";

export default class ReintegrateOrderAction extends LightningElement {
  @api recordId;
  @api invoke() {
    runIntegrationFromLWC({ orderId: this.recordId })
      .then(() => {
        NotifyFieldUpdates([{ recordId: this.recordId }]);
      })
      .catch((error) => {
        console.error("Error triggering integration:", error);
      });
  }
}
