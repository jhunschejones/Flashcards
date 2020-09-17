require 'test_helper'

# bundle exec ruby -Itest test/models/deck_test.rb
class DeckTest < ActiveSupport::TestCase
  describe "#shuffle" do
    it "shuffles the deck" do
      assert_changes -> { CardDeck.where(deck: decks(:study_now)).take(5) } do
        decks(:study_now).shuffle
      end
    end

    it "does not create duplicate card_deck positions" do
      deck = decks(:study_now)
      deck.shuffle
      deck.card_decks.pluck(:position).uniq.size == deck.card_decks.size
    end
  end

  describe "validations" do
    it "is not vaild with unrecognized start_with value" do
      deck = Deck.new(name: "My new deck", start_with: "space cats")
      expected_error = {:start_with=>["not included in '[\"kana\", \"kanji\", \"english\", \"audio_sample\"]'"]}

      refute deck.valid?
      assert_equal expected_error, deck.errors.messages
    end
  end
end
