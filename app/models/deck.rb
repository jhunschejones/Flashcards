class Deck < ApplicationRecord
  has_many :card_decks, dependent: :destroy
  has_many :cards, through: :card_decks

  validates :name, presence: true
  validate :start_with_valid

  VALID_START_WITH_VALUES = ["kana", "english", "audio_sample"]

  private

  def start_with_valid
    unless VALID_START_WITH_VALUES.include?(start_with)
      errors.add(:start_with, "not included in '#{VALID_START_WITH_VALUES}'")
    end
  end
end
