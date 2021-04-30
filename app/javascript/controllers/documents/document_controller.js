import { Controller } from "stimulus"

export default class extends Controller {
  static values = { url: String, id: String }

  edit() {
    this._fetchAndReplace(this.urlValue + "/edit")
  }

  cancelEdit(event) {
    event.preventDefault()
    this._fetchAndReplace(this.urlValue)
  }

  update(event) {
    event.preventDefault()
    let form = this.element.querySelector("form#doc_form_" + this.idValue)
    let formData = new FormData(form)
    this._fetchAndReplace(this.urlValue, {
      method: "PUT",
      body: formData
    })
  }
  
  _fetchAndReplace(url, opts = {}) {
    fetch(url, opts)
      .then(response => response.text())
      .then(data => {
        let parser = new DOMParser()
        return parser.parseFromString(data, "text/html")  
      })
      .then(response => {
        this.element.innerHTML = response.querySelector("#document_" + this.idValue).innerHTML
      })
  }
}