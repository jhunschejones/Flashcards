import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "studyNowButton" ];

  selectMaximumDifficulty(event) {
    this.clearSelectedMaximumDifficultyOptions();
    event.target.classList.toggle("is-white");
    event.target.classList.toggle("is-success");

    let data = new FormData();
    data.append("deck[maximum_difficulty]", event.target.innerHTML);
    Rails.ajax({ url: this.data.get("update-url"), type: 'PATCH', data: data, dataType: 'JSON' });
  }

  selectMinimumDifficulty(event) {
    this.clearSelectedMinimumDifficultyOptions();
    event.target.classList.toggle("is-white");
    event.target.classList.toggle("is-success");

    let data = new FormData();
    data.append("deck[minimum_difficulty]", event.target.innerHTML);
    Rails.ajax({ url: this.data.get("update-url"), type: 'PATCH', data: data, dataType: 'JSON' });
  }

  clearSelectedMaximumDifficultyOptions() {
    document.querySelectorAll(".button.maximum-difficulty.is-success").forEach((selectedButton) => {
      selectedButton.classList.toggle("is-success");
      selectedButton.classList.toggle("is-white");
    });
  }

  clearSelectedMinimumDifficultyOptions() {
    document.querySelectorAll(".button.minimum-difficulty.is-success").forEach((selectedButton) => {
      selectedButton.classList.toggle("is-success");
      selectedButton.classList.toggle("is-white");
    });
  }
}
