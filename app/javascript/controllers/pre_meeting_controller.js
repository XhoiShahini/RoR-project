import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["join"]
  connect() {}

  showLink() {
    this.joinTarget.classList.remove("hidden")
  }
}