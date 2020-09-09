import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "playAudioSampleButton" ]

  initialize() {
    if (this.hasPlayAudioSampleButtonTarget) {
      this.playAudioSampleButtonTarget.audio = new Audio(this.playAudioSampleButtonTarget.href);
    }
  }

  playAudio(e) {
    e.preventDefault();
    e.stopPropagation();
    e.currentTarget.audio.play();
  }
}
