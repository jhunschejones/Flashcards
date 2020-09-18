require 'test_helper'

# bundle exec ruby -Itest test/models/card_deck_test.rb
class CardDeckTest < ActiveSupport::TestCase
  describe "#move_to" do
    it "creates a new card_deck in the new deck" do
      assert_difference "CardDeck.where(deck: decks(:study_later)).count", 1 do
        card_decks(:cat_study_now).move_to(new_deck: decks(:study_later))
      end
    end

    it "doesnt create a duplicate record in the new deck" do
      CardDeck.create(card: cards(:cat), deck: decks(:study_later))
      assert_no_difference "CardDeck.where(deck: decks(:study_later)).count" do
        card_decks(:cat_study_now).move_to(new_deck: decks(:study_later))
      end
    end

    it "deletes the old card_deck record" do
      assert_difference "CardDeck.where(deck: decks(:study_now)).count", -1 do
        card_decks(:cat_study_now).move_to(new_deck: decks(:study_later))
      end
    end
  end
end
