class Deck < ApplicationRecord
  has_many :card_decks, dependent: :destroy
  has_many :cards, through: :card_decks

  validates :name, presence: true
  validate :start_with_valid

  VALID_START_WITH_VALUES = ["kana", "english", "audio_sample"].freeze

  def shuffle
    # This method suspends the auto-sorting callbacks while I manually change
    # position values. Without this card_deck positions end up with duplicates
    # or gaps, breaking the ordered deck functionality.
    CardDeck.acts_as_list_no_update do
      new_positions = (1..card_decks.size).to_a.shuffle
      card_decks.map { |card_deck| card_deck.update(position: new_positions.pop) }
    end
  end

  private

  def start_with_valid
    unless VALID_START_WITH_VALUES.include?(start_with)
      errors.add(:start_with, "not included in '#{VALID_START_WITH_VALUES}'")
    end
  end
end
