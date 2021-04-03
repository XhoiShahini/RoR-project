import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["details"]

  connect() {}

  toggle() {
    this.detailsTarget.classList.toggle("hidden")
  }
}