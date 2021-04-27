import { Controller } from "stimulus"

export default class extends Controller {
  static values = { documentId: String, meetingId: String, signed: Boolean }
  static targets = ["modal", "modalButton"]
  
  connect() {
  }

  documentIdValueChanged() {
    if (this.documentIdValue === "" || this.documentIdValue === null || this.documentIdValue === undefined) {
      return
    }
    let signatureUrl = "/meetings/" + this.meetingIdValue + "/documents/" + this.documentIdValue + "/new_signature"
    fetch(signatureUrl)
      .then(response => response.text())
      .then(data => {
        let parser = new DOMParser()
        return parser.parseFromString(data, "text/html")  
      })
      .then(response => {
        this.modalTarget.innerHTML = response.querySelector("#new_signature").innerHTML
      })
  }

  signedValueChanged() {
    this.modalButtonTarget.disabled = this.signedValue
  }
}