class Card < ApplicationRecord
  has_many :card_decks, dependent: :destroy
  has_many :decks, through: :card_decks
  has_one_attached :audio_sample

  validates :english, presence: true
  validates :japanese, presence: true

  def self.find_or_set_current_card_for(deck:)
    return if deck.cards.blank?
    current_card = CardDeck.includes(:card).find_by(deck: deck, status: CardDeck::CURRENT_CARD)&.card
    unless current_card.present?
      deck.card_decks.first.update(status: CardDeck::CURRENT_CARD)
      current_card = deck.card_decks.first.card
    end
    current_card
  end

  def self.set_next_card_for(deck:)
    ActiveRecord::Base.transaction do
      current_card = find_or_set_current_card_for(deck: deck)

      card_ids = deck.cards.map(&:id)
      next_card_id = card_ids[card_ids.find_index(current_card.id) + 1] || card_ids.first
      next_card = Card.find(next_card_id)

      CardDeck.find_by(deck: deck, card: current_card).update(status: "")
      CardDeck.find_by(deck: deck, card: next_card).update(status: CardDeck::CURRENT_CARD)

      next_card
    end
  end
end
