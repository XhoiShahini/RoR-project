import { Controller } from "stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static values = { id: String }
  connect() {
    this.subscription = consumer.subscriptions.create({ channel: "MeetingEventsChannel", meeting_id: this.idValue }, {
      connected: this._connected.bind(this),
      disconnected: this._disconnected.bind(this),
      received: this._received.bind(this)
    })
  }

  disconnect() {
    this.subscription.unsubscribe()
  }

  startSigning() {
    let signatureController = this.application.getControllerForElementAndIdentifier(document.querySelector("#signature-controller"), "signature")
    signatureController.signaturesReady()
  }

  allParticipantsVerified() {
    let signatureController = this.application.getControllerForElementAndIdentifier(document.querySelector("#signature-controller"), "signature")
    signatureController.allParticipantsVerified()
  }

  _connected() {}

  _disconnected() {}

  _received(data) {
    switch (data.type) {
      case "start":
        //TODO: Don't let participants in before host
        break;
      case "start_signing":
        this.startSigning()
        break;
      case "participants_verified":
        this.allParticipantsVerified()
        break;
      case "end":
        window.location.reload()
        break;
    }
  }

}