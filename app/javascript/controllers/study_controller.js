import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "englishText", "kanaText", "kanjiText", "audioSample", "loader", "cardOptions" ]

  initialize() {
    this.isFlipped = false;
    this.cardOptionsVisible = false;
    this.showFrontOfCard();
  }

  flipCard() {
    this.cardOptionsVisible = false;
    if(this.isFlipped) {
      this.isFlipped = false;
      return this.showFrontOfCard();
    }

    this.isFlipped = true;
    return this.showBackOfCard();
  }

  prepareForNextCard() {
    // Prevent flashing by blanking out current card content
    // before flipping to the front of the card
    this.englishTextTarget.innerHTML = "";
    this.kanaTextTarget.innerHTML = "";
    this.kanjiTextTarget.innerHTML = "";
    this.audioSampleTarget.innerHTML = "";

    this.loaderTarget.classList.add("is-active");

    this.cardOptionsVisible = false;
    this.isFlipped = false;

    this.clearSelectedDifficultyOptions();

    return this.showFrontOfCard();
  }

  showFrontOfCard() {
    this.cardOptionsTarget.style.display = "none";
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
    this.cardOptionsTarget.style.display = "none";
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

  showCardOptions() {
    this.englishTextTarget.style.display = "none";
    this.kanaTextTarget.style.display = "none";
    this.kanjiTextTarget.style.display = "none";
    if (this.hasAudioSampleTarget) {
      this.audioSampleTarget.style.display = "none";
    }

    this.cardOptionsTarget.style.display = "block";
  }

  toggleCardOptions() {
    if(this.cardOptionsVisible) {
      this.cardOptionsVisible = false;

      if(this.isFlipped) {
        return this.showBackOfCard();
      }
      return this.showFrontOfCard();
    }

    this.cardOptionsVisible = true;
    return this.showCardOptions();
  }

  setCardDifficulty(event) {
    this.clearSelectedDifficultyOptions();
    event.target.classList.toggle("is-light");
    event.target.classList.toggle("is-success");

    let data = new FormData();
    data.append("card[difficulty]", event.target.innerHTML);
    Rails.ajax({ url: this.data.get("card-update-url"), type: 'PATCH', data: data, dataType: 'JSON' });
  }

  clearSelectedDifficultyOptions() {
    document.querySelectorAll(".button.is-success").forEach((selectedButton) => {
      selectedButton.classList.toggle("is-success");
      selectedButton.classList.toggle("is-light");
    });
  }
}
