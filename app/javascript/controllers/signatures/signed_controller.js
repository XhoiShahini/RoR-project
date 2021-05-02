import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    let signatureController = this.application.getControllerForElementAndIdentifier(document.querySelector("#signature-controller"), "signature")
    signatureController.signedValue = true
    let modalController = this.application.getControllerForElementAndIdentifier(document.querySelector("#signature_modal"), "modal")
    modalController.close()
  }
}