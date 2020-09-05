class CardDeck < ApplicationRecord
  belongs_to :card
  belongs_to :deck, touch: true

  acts_as_list scope: :deck
  default_scope { order(position: :asc) }

  CURRENT_CARD = "current".freeze

  def self.find_or_set_current_card_deck(deck:)
    current_card_deck = CardDeck.find_by(deck: deck, status: CardDeck::CURRENT_CARD)
    unless current_card_deck.present?
      current_card_deck = deck.card_decks.first
      current_card_deck.update(status: CardDeck::CURRENT_CARD)
    end
    current_card_deck
  end
end
