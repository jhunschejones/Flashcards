import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "englishText", "kanaText", "kanjiText", "audioSample", "loader" ]

  initialize() {
    this.isFlipped = false;
    this.showFrontOfCard();
  }

  flipCard() {
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
    this.kanaTextTarget.innerHTML = "";
    this.kanjiTextTarget.innerHTML = "";
    this.audioSampleTarget.innerHTML = "";
    this.loaderTarget.classList.add("is-active");

    if(this.isFlipped) {
      // Flip card to the front to prepare for next card
      this.isFlipped = false;
      return this.showFrontOfCard();
    }
  }

  prepareForMoveCard() {
    // Don't flip the card and start the spinner when move card button
    // is pressed unless the user has selected a new deck
    if (document.querySelector(".new-deck-select").value != "") {
      this.prepareForNextCard();
    }
  }

  showFrontOfCard() {
    switch(this.data.get("startWith")) {
      case "english":
        this.englishTextTarget.style.display = "block";
        this.kanaTextTarget.style.display = "none";
        this.kanjiTextTarget.style.display = "none";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "none";
        }
        break;
      case "kanji":
        this.englishTextTarget.style.display = "none";
        this.kanaTextTarget.style.display = "none";
        this.kanjiTextTarget.style.display = "block";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "none";
        }
        break;
      case "audio_sample":
        this.englishTextTarget.style.display = "none";
        this.kanaTextTarget.style.display = "none";
        this.kanjiTextTarget.style.display = "none";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "block";
        }
        break;
      default:
        this.englishTextTarget.style.display = "none";
        this.kanaTextTarget.style.display = "block";
        this.kanjiTextTarget.style.display = "none";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "none";
        }
    }
  }

  showBackOfCard() {
    switch(this.data.get("startWith")) {
      case "english":
        this.englishTextTarget.style.display = "none";
        this.kanaTextTarget.style.display = "block";
        this.kanjiTextTarget.style.display = "block";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "block";
        }
        break;
      case "kanji":
        this.englishTextTarget.style.display = "block";
        this.kanaTextTarget.style.display = "block";
        this.kanjiTextTarget.style.display = "none";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "block";
        }
        break;
      case "audio_sample":
        this.englishTextTarget.style.display = "block";
        this.kanaTextTarget.style.display = "block";
        this.kanjiTextTarget.style.display = "block";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "none";
        }
        break;
      default:
        this.englishTextTarget.style.display = "block";
        this.kanaTextTarget.style.display = "none";
        this.kanjiTextTarget.style.display = "block";
        if (this.hasAudioSampleTarget) {
          this.audioSampleTarget.style.display = "block";
        }
    }
  }
}
