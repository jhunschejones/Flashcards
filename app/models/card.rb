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

      next_card_deck = CardDeck.find_next(deck: deck, current_card_deck: current_card_deck)

      if deck.is_randomized? && (next_card_deck == deck.card_decks.first)
        deck.shuffle
        deck.card_decks.reload
        next_card_deck = deck.card_decks.first
      end

      current_card_deck.update(status: nil)
      next_card_deck.update(status: CardDeck::CURRENT_CARD)

      next_card_deck.card
    end
  end

  def self.previous_card_in(deck:)
    ActiveRecord::Base.transaction do
      current_card_deck = CardDeck.find_or_set_current_card_deck(deck: deck)
      return unless current_card_deck.present?

      previous_card_deck = CardDeck.find_previous(deck: deck, current_card_deck: current_card_deck)
      current_card_deck.update(status: nil)
      previous_card_deck.update(status: CardDeck::CURRENT_CARD)

      previous_card_deck.card
    end
  end
end
