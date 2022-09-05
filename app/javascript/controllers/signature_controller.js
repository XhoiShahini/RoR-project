import { Controller } from "stimulus"

export default class extends Controller {
  static values = { documentId: String, meetingId: String, signed: Boolean, readonly: Boolean }
  static targets = ["modal", "modalButton", "commit", "startSigning", "tooltip"]

  __pdfOnsave = null

  connect() {
    if(this.hasStartSigningTarget) {
      this.modalButtonTarget.classList.add("hidden")
    }
  }

  documentIdValueChanged() {
    if (this.documentIdValue === "" || this.documentIdValue === null || this.documentIdValue === undefined) {
      return
    }
    let signatureUrl = "/meetings/" + this.meetingIdValue + "/documents/" + this.documentIdValue + "/new_signature"
    this._fetchAndReplace(signatureUrl)
  }

  signedValueChanged() {
    console.debug('signedValueChanged', this.signedValue)
    this.modalButtonTarget.disabled = this.signedValue
  }

  readonlyValueChanged() {
    console.debug('readonlyValueChanged', this.readonlyValue)
    this.modalButtonTarget.classList.toggle("hidden", this.readonlyValue)
  }

  setPDFSaveCallback(onSave) {
    console.log('setting setPDFSaveCallback to ', onSave);
    this.__pdfOnsave = onSave

    this.signedValue = false
  }

  async sendOTP() {

    // merge PDF
    if (typeof this.__pdfOnsave === 'function') {
      await this.__pdfOnsave()
    } else {
      throw new Error('Missing __pdfOnsave!')
    }

    let otpUrl = "/meetings/" + this.meetingIdValue + "/documents/" + this.documentIdValue + "/otp"
    this._fetchAndReplace(otpUrl)
  }

  allowSignatures() {
    let url = "/meetings/" + this.meetingIdValue + "/allow_signatures"
    fetch(url)
  }

  signaturesReady() {
    if (this.hasStartSigningTarget) {
      this.startSigningTarget.classList.add("hidden")
      this.modalButtonTarget.classList.remove("hidden")
    }
    this.reset()
  }

  allParticipantsVerified() {
    if (this.hasStartSigningTarget) {
      this.startSigningTarget.disabled = false
      this.tooltipTarget.replaceWith(this.startSigningTarget)
    }
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
