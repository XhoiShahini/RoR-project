import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "useVideo", "datePicker" ]
  connect() {
    console.log('form connected')
    this.datePickerTarget.hidden = true;
  }

  toggleDate(){
    this.datePickerTarget.hidden = !this.useVideoTarget.checked;
  }
}
