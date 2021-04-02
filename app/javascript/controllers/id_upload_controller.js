import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    Promise.resolve().then(() => {
      let preMeetingController = this.application.getControllerForElementAndIdentifier(document.querySelector("#controller"), "pre-meeting")
      preMeetingController.showLink()
    })
  }
}