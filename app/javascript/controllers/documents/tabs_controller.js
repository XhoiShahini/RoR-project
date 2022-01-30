import { Controller } from "stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static values = { id: String }
  connect() {
    this.subscription = consumer.subscriptions.create({ channel: "DocumentsChannel", meeting_id: this.idValue }, {
      connected: this._connected.bind(this),
      disconnected: this._disconnected.bind(this),
      received: this._received.bind(this)
    })
    Promise.resolve().then(() => {
      this._initViewer(this._loadDocuments())
    })
  }

  disconnect() {
    this.subscription.unsubscribe()
  }

  _loadDocuments() {
    return fetch("/meetings/" + this.idValue + "/documents/tabs")
      .then(response => response.text())
      .then(data => {
        let parser = new DOMParser()
        return parser.parseFromString(data, "text/html")
      })
      .then(response => {
        this.element.innerHTML = response.querySelector("#documents").innerHTML
      })
  }

  _initViewer(promise) {
    promise.then(() => {
      // FIXME: ?
      // const pdfController = this.application.getControllerForElementAndIdentifier(document.querySelector("#pdf-controller"), "documents--pdf")
      // pdfController._initTabs()
    })
  }

  _connected() {}

  _disconnected() {}

  _received(data) {
    switch (data.type) {
      case "create":
        this._loadDocuments()
        break;
      case "update":
        this._loadDocuments()
        break;
      case "destroy":
        this._loadDocuments()
        break;
    }
  }
}
