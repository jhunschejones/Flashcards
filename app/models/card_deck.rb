class CardDeck < ApplicationRecord
  belongs_to :card
  belongs_to :deck, touch: true
  validates :card_id, uniqueness: { scope: :deck_id }

  acts_as_list scope: :deck
  default_scope { order(position: :asc) }

  CURRENT_CARD = "current".freeze

  def move_to(new_deck:)
    CardDeck.transaction(requires_new: true) do
      moved_card_deck = CardDeck.create_if_not_exists(card: card, deck: new_deck)
      self.destroy
      moved_card_deck
    end
  end
end
