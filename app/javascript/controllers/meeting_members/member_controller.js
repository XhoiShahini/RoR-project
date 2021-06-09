import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["details"]
  static values = { isParticipant: Boolean, url: String, id: String }

  connect() {}

  toggle() {
    this.detailsTarget.classList.toggle("hidden")
  }

  edit() {
    this._fetchAndReplace(this.urlValue + "/edit")
  }

  cancelEdit(event) {
    event.preventDefault()
    this._fetchAndReplace(this.urlValue)
  }

  update(event) {
    event.preventDefault()
    let form = this.element.querySelector("form#mm_form_" + this.idValue)
    let phoneNumberController = this.application.getControllerForElementAndIdentifier(form, "phone-number")
    if (!phoneNumberController.iti.isValidNumber()) { return }
    let formData = new FormData(form)
    this._fetchAndReplace(this.urlValue, {
      method: "PUT",
      body: formData
    })
  }

  verifyMember() {
    fetch(this.urlValue + "/verify")
  }

  resend() {
    fetch(this.urlValue + "/resend_invite")
  }
  
  _fetchAndReplace(url, opts = {}) {
    fetch(url, opts)
      .then(response => response.text())
      .then(data => {
        let parser = new DOMParser()
        return parser.parseFromString(data, "text/html")  
      })
      .then(response => {
        this.element.innerHTML = response.querySelector("#meeting_member_" + this.idValue).innerHTML
      })
  }
}