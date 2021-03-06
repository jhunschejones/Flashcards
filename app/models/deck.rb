class Deck < ApplicationRecord
  has_many :card_decks, dependent: :destroy
  has_many :cards, through: :card_decks

  validates :name, presence: true
  validates :maximum_difficulty, inclusion: { in: Card::DIFFICULTIES }
  validates :minimum_difficulty, inclusion: { in: Card::DIFFICULTIES }
  validate :start_with_valid

  VALID_START_WITH_VALUES = ["kana", "kanji", "english", "audio_sample"].freeze

  def shuffle
    # This method suspends the auto-sorting callbacks while I manually change
    # position values. Without this card_deck positions end up with duplicates
    # or gaps, breaking the ordered deck functionality.
    CardDeck.acts_as_list_no_update do
      new_positions = (1..card_decks.size).to_a.shuffle
      card_decks.map { |card_deck| card_deck.update(position: new_positions.pop) }
    end
    CardDeck.where(deck: self, status: CardDeck::CURRENT_CARD).update(status: nil)
    self
  end

  def cards_to_study(shuffled = false)
    if shuffled
      # Reset cache if deck was just shuffled
      @cards_to_study = cards.where(difficulty: minimum_difficulty..maximum_difficulty)
    end
    @cards_to_study ||= cards.where(difficulty: minimum_difficulty..maximum_difficulty)
  end

  def current_card
    Card.joins(card_decks: [:deck]).where(
      card_decks: { deck_id: id, status: CardDeck::CURRENT_CARD },
      difficulty: minimum_difficulty..maximum_difficulty
    ).first || begin
      current_card = cards_to_study.first
      CardDeck.where(deck: self, status: CardDeck::CURRENT_CARD).update(status: nil)
      CardDeck.find_by(deck: self, card: current_card)&.update(status: CardDeck::CURRENT_CARD)
      current_card
    end
  end

  def next_card
    Deck.transaction(requires_new: true) do
      index = cards_to_study.index { |c| c.id == current_card.id }
      return unless index.present?
      next_card = cards_to_study[index + 1] || begin
        is_randomized ? shuffle.reload.cards_to_study(true)[0] : cards_to_study[0]
      end
      CardDeck.where(deck: self, status: CardDeck::CURRENT_CARD).update(status: nil)
      CardDeck.find_by(deck: self, card: next_card).update(status: CardDeck::CURRENT_CARD)
      next_card
    end
  end

  def previous_card
    Deck.transaction(requires_new: true) do
      index = cards_to_study.index { |c| c.id == current_card.id }
      return unless index.present?
      previous_card = cards_to_study[index - 1]
      CardDeck.where(deck: self, status: CardDeck::CURRENT_CARD).update(status: nil)
      CardDeck.find_by(deck: self, card: previous_card).update(status: CardDeck::CURRENT_CARD)
      previous_card
    end
  end

  def progress
    current_card_position = cards_to_study.index { |c| c.id == current_card.id }
    return unless current_card_position
    "#{current_card_position + 1} / #{cards_to_study.size}"
  end

  private

  def start_with_valid
    unless VALID_START_WITH_VALUES.include?(start_with)
      errors.add(:start_with, "not included in '#{VALID_START_WITH_VALUES}'")
    end
  end
end
