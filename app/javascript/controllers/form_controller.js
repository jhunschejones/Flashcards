import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "fileInput", "fileName" ];

  showFileName() {
    this.fileNameTarget.style.display = "block";
    this.fileNameTarget.textContent = this.fileInputTarget.files[0].name;
  }
}
