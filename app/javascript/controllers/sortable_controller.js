import { Controller } from "stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
    this.sortable = Sortable.create(this.element, {
      group: 'shared',
      animation: 150,
      onEnd: this.end.bind(this)
    })
  }

  end(event) {
    let data = new FormData()
    data.append("position", event.newIndex + 1)
    data.append("card_id", event.item.dataset.cardId)
    data.append("deck_id", event.item.dataset.deckId)

    Rails.ajax({
      url: this.data.get("url"),
      type: 'PATCH',
      data: data
    })
  }
}
