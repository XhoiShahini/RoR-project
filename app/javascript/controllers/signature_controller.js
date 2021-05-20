import { Controller } from "stimulus"

export default class extends Controller {
  static values = { documentId: String, meetingId: String, signed: Boolean, readonly: Boolean }
  static targets = ["modal", "modalButton", "commit"]
  
  connect() {
  }

  documentIdValueChanged() {
    if (this.documentIdValue === "" || this.documentIdValue === null || this.documentIdValue === undefined) {
      return
    }
    let signatureUrl = "/meetings/" + this.meetingIdValue + "/documents/" + this.documentIdValue + "/new_signature"
    this._fetchAndReplace(signatureUrl)
  }

  signedValueChanged() {
    this.modalButtonTarget.disabled = this.signedValue
  }

  readonlyValueChanged() {
    this.modalButtonTarget.classList.toggle("hidden", this.readonlyValue)
  }

  sendOTP() {
    let otpUrl = "/meetings/" + this.meetingIdValue + "/documents/" + this.documentIdValue + "/otp"
    this._fetchAndReplace(otpUrl)
  }

  reset() {
    this.documentIdValueChanged()
  }

  verifyOTP(event) {
    event.stopPropagation()
    event.preventDefault()
    let form = event.target
    let formData = new FormData(form)
    let otpUrl = "/meetings/" + this.meetingIdValue + "/documents/" + this.documentIdValue + "/verify_otp"
    fetch(otpUrl, {
      method: "POST",
      body: formData
    })
      .then(response => response.text())
      .then(data => {
        let parser = new DOMParser()
        return parser.parseFromString(data, "text/html")  
      })
      .then(response => {
        this.modalTarget.innerHTML = response.querySelector("#new_signature").innerHTML
      })
    return false
  }

  sign() {
    let signUrl = "/meetings/"+ this.meetingIdValue + "/documents/" + this.documentIdValue + "/sign"
    this._fetchAndReplace(signUrl)
  }

  participantVerifyId(event) {
    this.commitTarget.classList.toggle("hidden", !event.target.checked)
  }

  _fetchAndReplace(url) {
    fetch(url)
      .then(response => response.text())
      .then(data => {
        let parser = new DOMParser()
        return parser.parseFromString(data, "text/html")  
      })
      .then(response => {
        this.modalTarget.innerHTML = response.querySelector("#new_signature").innerHTML
      })
  }
}