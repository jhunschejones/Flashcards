class Card < ApplicationRecord
  has_many :card_decks, dependent: :destroy
  has_many :decks, through: :card_decks
  has_one_attached :audio_sample

  validates :english, presence: true
  validates :kana, presence: true

  before_save :trim_text_values

  def self.find_or_set_current_card_for(deck:)
    CardDeck.find_or_set_current_card_deck(deck: deck)&.card
  end

  def self.next_card_in(deck:)
    ActiveRecord::Base.transaction do
      current_card_deck = CardDeck.find_or_set_current_card_deck(deck: deck)
      return unless current_card_deck.present?

      next_card_deck = CardDeck.find_next(deck: deck, current_card_deck: current_card_deck)
      next_card_deck = deck.shuffle.card_decks.reload.first if next_card_deck.should_shuffle?

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

  private

  def trim_text_values
    self.english = self.english&.strip
    self.kana = self.kana&.strip
    self.kanji = self.kanji&.strip
  end
end
