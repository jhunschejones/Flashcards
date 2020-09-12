require 'test_helper'

# bundle exec ruby -Itest test/models/card_deck_test.rb
class CardDeckTest < ActiveSupport::TestCase
  describe ".find_or_set_current_card_deck" do
    it "returns the current card_deck when set" do
      card_decks(:cat_study_now).update(status: nil)
      card_decks(:dog_study_now).update(status: "current")
      assert_equal card_decks(:dog_study_now), CardDeck.find_or_set_current_card_deck(deck: decks(:study_now))
    end

    it "returns the first card_deck when current is not set" do
      card_decks(:cat_study_now).update(status: nil)
      assert_equal card_decks(:cat_study_now), CardDeck.find_or_set_current_card_deck(deck: decks(:study_now))
    end

    it "sets the current card_deck when it is not set" do
      card_decks(:cat_study_now).update(status: nil)
      assert_nil card_decks(:cat_study_now).status
      CardDeck.find_or_set_current_card_deck(deck: decks(:study_now))
      card_decks(:cat_study_now).reload
      assert_equal "current", card_decks(:cat_study_now).status
    end

    it "returns nil when there are no card_decks in the deck" do
      assert_nil CardDeck.find_or_set_current_card_deck(deck: decks(:study_later))
    end
  end

  describe ".find_previous" do
    it "returns previous positioned card_deck" do
      assert_equal card_decks(:cat_study_now), CardDeck.find_previous(deck: decks(:study_now), current_card_deck: card_decks(:dog_study_now))
    end

    it "returns last card_deck when first card_deck is passed in" do
      assert_equal card_decks(:glass_study_now), CardDeck.find_previous(deck: decks(:study_now), current_card_deck: card_decks(:cat_study_now))
    end
  end

  describe ".find_next" do
    it "returns next positioned card_deck" do
      assert_equal card_decks(:house_study_now), CardDeck.find_next(deck: decks(:study_now), current_card_deck: card_decks(:dog_study_now))
    end

    it "returns first card_deck when last card_deck is passed in" do
      assert_equal card_decks(:cat_study_now), CardDeck.find_next(deck: decks(:study_now), current_card_deck: card_decks(:glass_study_now))
    end
  end

  describe "#move" do
    it "creates a new card_deck for the new_deck" do
      assert_difference "CardDeck.where(card: cards(:cat), deck: decks(:study_later)).count", 1 do
        card_decks(:cat_study_now).move(new_deck: decks(:study_later))
      end
    end

    it "deletes the old card_deck" do
      assert_difference "CardDeck.where(card: cards(:cat), deck: decks(:study_now)).count", -1 do
        card_decks(:cat_study_now).move(new_deck: decks(:study_later))
      end
    end

    it "returns the new card_deck" do
      new_card_deck = card_decks(:cat_study_now).move(new_deck: decks(:study_later))
      assert_equal decks(:study_later), new_card_deck.deck
      assert_equal cards(:cat), new_card_deck.card
    end

    describe "when a card_deck already exists in the new_deck" do
      before do
        CardDeck.create(deck: decks(:study_later), card: cards(:cat))
      end

      it "does not create a new card_deck" do
        assert_no_difference "CardDeck.where(card: cards(:cat), deck: decks(:study_later)).count" do
          card_decks(:cat_study_now).move(new_deck: decks(:study_later))
        end
      end

      it "deletes the old card_deck" do
        assert_difference "CardDeck.where(card: cards(:cat), deck: decks(:study_now)).count", -1 do
          card_decks(:cat_study_now).move(new_deck: decks(:study_later))
        end
      end

      it "returns the new card_deck" do
        new_card_deck = card_decks(:cat_study_now).move(new_deck: decks(:study_later))
        assert_equal decks(:study_later), new_card_deck.deck
        assert_equal cards(:cat), new_card_deck.card
      end
    end
  end

  describe "#should_shuffle?" do
    it "returns false if card_deck is not first" do
      refute card_decks(:house_study_now).should_shuffle?
    end

    it "returns false if the deck is not randomized" do
      refute card_decks(:cat_study_now).should_shuffle?
    end

    it "returns true if the card is first and the deck is randomized" do
      decks(:study_now).update(is_randomized: true)
      assert card_decks(:cat_study_now).should_shuffle?
    end
  end
end
