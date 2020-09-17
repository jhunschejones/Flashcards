import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "studyNowButton" ];

  selectDifficulty(event) {
    this.clearSelectedDifficultyOptions();
    event.target.classList.toggle("is-white");
    event.target.classList.toggle("is-success");

    let data = new FormData();
    data.append("deck[maximum_difficulty]", event.target.innerHTML);
    Rails.ajax({ url: this.data.get("update-url"), type: 'PATCH', data: data, dataType: 'JSON' });
  }

  clearSelectedDifficultyOptions() {
    document.querySelectorAll(".button.is-success").forEach((selectedButton) => {
      selectedButton.classList.toggle("is-success");
      selectedButton.classList.toggle("is-white");
    });
  }
}
