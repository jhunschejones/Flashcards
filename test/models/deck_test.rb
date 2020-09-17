require 'test_helper'

# bundle exec ruby -Itest test/models/deck_test.rb
class DeckTest < ActiveSupport::TestCase
  describe "validations" do
    it "is not vaild with unrecognized start_with value" do
      deck = Deck.new(name: "My new deck", start_with: "space cats")
      expected_error = {:start_with=>["not included in '[\"kana\", \"kanji\", \"english\", \"audio_sample\"]'"]}

      refute deck.valid?
      assert_equal expected_error, deck.errors.messages
    end
  end

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

  describe "#cards_to_study" do
    before do
      cards(:house).update(difficulty: 1)
      decks(:study_now).update(minimum_difficulty: 2)
    end

    it "returns only cards matching selected difficulty range" do
      assert_equal 11, decks(:study_now).cards_to_study.size
    end

    it "returns new set of cards after shuffling" do
      assert_changes -> { Deck.find(decks(:study_now).id).cards_to_study.take(5) } do
        decks(:study_now).shuffle
      end
    end
  end

  describe "#current_card" do
    it "returns nil when no cards match" do
      decks(:study_now).update(maximum_difficulty: 1)
      refute decks(:study_now).current_card
    end

    it "returns card set as current when difficulty matches" do
      assert_equal cards(:cat), decks(:study_now).current_card
    end

    describe "when current card does not match difficulty" do
      before do
        cards(:cat).update(difficulty: 1)
        decks(:study_now).update(minimum_difficulty: 2)
      end

      it "returns and first matching card" do
        assert_equal cards(:dog), decks(:study_now).current_card
      end

      it "sets first matching card to current" do
        assert_changes -> { CardDeck.find_by(deck: decks(:study_now), card: cards(:dog)).status } do
          decks(:study_now).current_card
        end
        assert_equal "current", card_decks(:dog_study_now).status
      end
    end
  end

  describe "#next_card" do
    it "returns nil when no next card matches" do
      decks(:study_now).update(maximum_difficulty: 1)
      refute decks(:study_now).next_card
    end

    it "returns the next card when difficulty matches" do
      assert_equal cards(:dog), decks(:study_now).next_card
    end

    it "updates which card is set as current" do
      assert_equal "current", card_decks(:cat_study_now).status
      decks(:study_now).next_card
      assert_equal Array(card_decks(:dog_study_now)), CardDeck.where(deck: decks(:study_now), status: "current")
    end

    describe "when deck is set to auto-shuffle" do
      before do
        decks(:study_now).update(is_randomized: true)
      end

      it "returns the next card as expected" do
        card_decks(:cat_study_now).update(status: nil)
        card_decks(:water_study_now).update(status: "current")
        assert_equal cards(:glass), decks(:study_now).next_card
      end

      it "shuffles the deck at the end" do
        card_decks(:cat_study_now).update(status: nil)
        card_decks(:glass_study_now).update(status: "current")
        assert_changes -> { CardDeck.where(deck_id: decks(:study_now).id).take(5) } do
          decks(:study_now).next_card
        end
      end
    end
  end

  describe "#previous card" do
    it "returns nil when no next card matches" do
      decks(:study_now).update(maximum_difficulty: 1)
      refute decks(:study_now).previous_card
    end

    it "returns the previous card when difficulty matches" do
      assert_equal cards(:glass), decks(:study_now).previous_card
    end

    it "updates which card is set as current" do
      assert_equal "current", card_decks(:cat_study_now).status
      decks(:study_now).previous_card
      assert_equal Array(card_decks(:glass_study_now)), CardDeck.where(deck: decks(:study_now), status: "current")
    end
  end

  describe "#progress" do
    it "returns expected string showing deck progress" do
      assert_equal "1 / 12", decks(:study_now).progress
    end

    it "returns nil when no cards match" do
      decks(:study_now).update(maximum_difficulty: 1)
      refute decks(:study_now).progress
    end
  end
end
