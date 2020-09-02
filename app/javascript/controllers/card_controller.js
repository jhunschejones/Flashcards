import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "englishText", "japaneseText", "audioSample" ]

  initialize() {
    this.isFlipped = false;
    this.showFrontOfCard();
  }

  flip() {
    if(this.isFlipped) {
      this.isFlipped = false;
      return this.showFrontOfCard();
    }

    this.isFlipped = true;
    return this.showBackOfCard();
  }

  prepareForNextCard() {
    // Prevent flashing by blanking out current card content
    this.englishTextTarget.innerHTML = "";
    this.japaneseTextTarget.innerHTML = "";
    this.audioSampleTarget.innerHTML = "";

    if(this.isFlipped) {
      // Flip card to the front to prepare for next card
      this.isFlipped = false;
      return this.showFrontOfCard();
    }
  }

  showFrontOfCard() {
    switch(this.data.get("startWith")) {
      case "english":
        this.englishTextTarget.style.display = "block";
        this.japaneseTextTarget.style.display = "none";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "none";
        }
        break;
      case "audio_sample":
        this.englishTextTarget.style.display = "none";
        this.japaneseTextTarget.style.display = "none";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "block";
        }
        break;
      default:
        this.englishTextTarget.style.display = "none";
        this.japaneseTextTarget.style.display = "block";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "none";
        }
    }
  }

  showBackOfCard() {
    switch(this.data.get("startWith")) {
      case "english":
        this.englishTextTarget.style.display = "none";
        this.japaneseTextTarget.style.display = "block";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "block";
        }
        break;
      case "audio_sample":
        this.englishTextTarget.style.display = "block";
        this.japaneseTextTarget.style.display = "block";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "none";
        }
        break;
      default:
        this.englishTextTarget.style.display = "block";
        this.japaneseTextTarget.style.display = "none";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "block";
        }
    }
  }
}
