class CardDeck < ApplicationRecord
  belongs_to :card
  belongs_to :deck, touch: true

  acts_as_list scope: :deck
  default_scope { order(position: :asc) }

  CURRENT_CARD = "current".freeze
end
