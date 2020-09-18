class Card < ApplicationRecord
  DIFFICULTIES = (1..5).to_a.freeze

  has_many :card_decks, dependent: :destroy
  has_many :decks, through: :card_decks
  has_one_attached :audio_sample

  validates :english, presence: true
  validates :kana, presence: true
  validates :difficulty, inclusion: { in: DIFFICULTIES }

  before_save :trim_text_values

  private

  def trim_text_values
    self.english = self.english&.strip
    self.kana = self.kana&.strip
    self.kanji = self.kanji&.strip
  end
end
