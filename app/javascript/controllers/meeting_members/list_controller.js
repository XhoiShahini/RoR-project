import { Controller } from "stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static values = { id: String }
  connect() {
    this.subscription = consumer.subscriptions.create({ channel: "MeetingMembersChannel", meeting_id: this.idValue }, {
      connected: this._connected.bind(this),
      disconnected: this._disconnected.bind(this),
      received: this._received.bind(this)
    })
  }

  disconnect() {
    this.subscription.unsubscribe()
  }

  _loadMembers() {
    fetch("/meetings/" + this.idValue + "/members")
      .then(response => response.text())
      .then(data => {
        let parser = new DOMParser()
        return parser.parseFromString(data, "text/html")  
      })
      .then(response => {
        this.element.innerHTML = response.querySelector("#meeting_members").innerHTML
      })
    let signatureController = this.application.getControllerForElementAndIdentifier(document.querySelector('div[data-controller="signature"]'), "signature")
    signatureController.documentIdValueChanged()
  }

  _connected() {
    console.log('CONNECTED')
  }

  _disconnected() {}

  _received(data) {
    console.log(data)
    switch (data.type) {
      case "create":
        this._loadMembers()
        break;
      case "update":
        this._loadMembers()
        break;
      case "destroy":
        this._loadMembers()
        break;
      case "presence":
        console.log(data);
        break;
    }
  }
}