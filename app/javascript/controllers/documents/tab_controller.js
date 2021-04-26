import { Controller } from "stimulus"

export default class extends Controller {
  static values = { id: String }
  switch() {
    console.log("switch")
    Promise.resolve().then(() => {
      document.querySelectorAll("div[data-controller=documents--tab]").forEach(tab => {
        tab.querySelector(".card").classList.remove("active")
      })
      this.element.querySelector(".card").classList.add("active")
      const pdfController = this.application.getControllerForElementAndIdentifier(document.querySelector("#pdf-controller"), "documents--pdf")
      pdfController.idValue = this.idValue
    })
  }
}