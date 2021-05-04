import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = { loadWith: String }
  connect() {
  }

  loading() {
    this.buttonTarget.disabled = true
    this.buttonTarget.classList.remove("btn-primary")
    this.buttonTarget.classList.add("btn-tertiary")
    this.buttonTarget.innerHTML = this.loadWithValue
  }
}
