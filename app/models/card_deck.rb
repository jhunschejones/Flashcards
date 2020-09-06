class CardDeck < ApplicationRecord
  belongs_to :card
  belongs_to :deck, touch: true

  acts_as_list scope: :deck
  default_scope { order(position: :asc) }

  CURRENT_CARD = "current".freeze

  def self.find_or_set_current_card_deck(deck:)
    current_card_deck = find_by(deck: deck, status: CURRENT_CARD)
    unless current_card_deck.present?
      current_card_deck = deck.card_decks.first
      current_card_deck.update(status: CURRENT_CARD)
    end
    current_card_deck
  end

  def self.find_previous(deck:, current_card_deck:)
    find_by(
        position: current_card_deck.position - 1,
        deck_id: current_card_deck.deck_id
    ) || deck.card_decks.last
  end

  def self.find_next(deck:, current_card_deck:)
    find_by(
      position: current_card_deck.position.next,
      deck_id: current_card_deck.deck_id
    ) || deck.card_decks.first
  end
end
