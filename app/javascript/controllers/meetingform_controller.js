import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "isAsync", "datePicker" ]
  connect() {
    console.log('form connected')
  }

  toggleDate(){
    this.datePickerTarget.hidden = this.isAsyncTarget.checked;
  }
}
