import { Controller } from "stimulus"
import intlTelInput from "intl-tel-input"

export default class extends Controller {
  static targets = ["input", "error", "valid", "hidden"]

  connect() {
    this.iti = intlTelInput(this.inputTarget, {
      utilsScript: "/phone_input_utils",
      separateDialCode: true,
      initialCountry: "it"
    })
  }

  update() {
    this.reset()
    this.hiddenTarget.value = this.iti.getNumber()
    if (this.inputTarget.value.trim()) {
      if (this.iti.isValidNumber()) {
        this.inputTarget.classList.add("border-secondary-500")
        this.validTarget.classList.remove("hidden")
      } else {
        this.inputTarget.classList.add("error")
        this.errorTarget.classList.remove("hidden")
      }
    }
  }

  reset() {
    this.inputTarget.classList.remove("error")
    this.inputTarget.classList.remove("border-green-300")
    this.errorTarget.classList.add("hidden")
    this.validTarget.classList.add("hidden")
  }
}
