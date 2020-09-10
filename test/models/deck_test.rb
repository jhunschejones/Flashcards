require 'test_helper'

# bundle exec ruby -Itest test/models/deck_test.rb
class DeckTest < ActiveSupport::TestCase
  describe "#shuffle" do
    it "shuffles the deck" do
      assert_changes -> { CardDeck.where(deck: decks(:study_now)).take(5) } do
        decks(:study_now).shuffle
      end
    end

    it "sets was_just_shuffled property for the deck" do
      deck = decks(:study_now)
      assert_nil deck.was_just_shuffled
      deck.shuffle
      assert deck.was_just_shuffled
    end
  end
end
