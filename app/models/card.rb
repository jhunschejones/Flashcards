class Card < ApplicationRecord
  has_many :card_decks, dependent: :destroy
  has_many :decks, through: :card_decks
  has_one_attached :audio_sample

  validates :english, presence: true
  validates :kana, presence: true

  def self.find_or_set_current_card_for(deck:)
    return if deck.cards.blank?
    CardDeck.find_or_set_current_card_deck(deck: deck).card
  end

  def self.next_card_in(deck:)
    ActiveRecord::Base.transaction do
      current_card_deck = CardDeck.find_or_set_current_card_deck(deck: deck)
      return unless current_card_deck.present?

      if deck.card_decks.remaining.size.zero?
        deck.card_decks.where(status: CardDeck::COMPLETED_CARD).update(status: "")
      end

      if deck.is_randomized?
        next_card_deck = deck.card_decks.remaining.sample
      end

      next_card_deck ||= CardDeck.find_next(deck: deck, current_card_deck: current_card_deck)

      CardDeck.where(status: CardDeck::PREVIOUS_CARD).update(status: CardDeck::COMPLETED_CARD)
      current_card_deck.update(status: CardDeck::PREVIOUS_CARD)
      next_card_deck.update(status: CardDeck::CURRENT_CARD)

      next_card_deck.card
    end
  end

  def self.previous_card_in(deck:)
    ActiveRecord::Base.transaction do
      current_card_deck = CardDeck.find_or_set_current_card_deck(deck: deck)
      return unless current_card_deck.present?

      previous_card_deck = CardDeck.find_previous(deck: deck, current_card_deck: current_card_deck)
      current_card_deck.update(status: "")
      previous_card_deck.update(status: CardDeck::CURRENT_CARD)

      previous_card_deck.card
    end
  end
end
