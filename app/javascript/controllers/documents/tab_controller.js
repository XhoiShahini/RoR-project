import { Controller } from "stimulus"

export default class extends Controller {
  static values = { id: String, signed: Boolean, readonly: Boolean }
  switch() {
    console.log("switch")
    Promise.resolve().then(() => {
      document.querySelectorAll("div[data-controller=documents--tab]").forEach(tab => {
        tab.querySelector(".card").classList.remove("active")
      })
      this.element.querySelector(".card").classList.add("active")
      const pdfController = this.application.getControllerForElementAndIdentifier(document.querySelector("#pdf-controller"), "documents--pdf")
      pdfController.idValue = this.idValue
      const signatureController = this.application.getControllerForElementAndIdentifier(document.querySelector("#signature-controller"), "signature")
      if (signatureController) {
        signatureController.signedValue = this.signedValue
        signatureController.readonlyValue = this.readonlyValue
        signatureController.documentIdValue = this.idValue
      }
    })
  }
}
