import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "form" ]

  toggle() {
    Rails.fire(this.formTarget, 'submit');
  }
}
