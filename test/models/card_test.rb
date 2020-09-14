require 'test_helper'

# bundle exec ruby -Itest test/models/card_test.rb
class CardTest < ActiveSupport::TestCase
  describe ".find_or_set_current_card_for" do
    it "finds the current deck when one is set" do
      card_decks(:cat_study_now).update(status: nil)
      card_decks(:dog_study_now).update(status: "current")
      assert_equal cards(:dog), Card.find_or_set_current_card_for(deck: decks(:study_now))
    end

    it "selects the first card in the deck when one is not set" do
      card_decks(:cat_study_now).update(status: nil)
      assert_equal cards(:cat), Card.find_or_set_current_card_for(deck: decks(:study_now))
    end

    it "returns nil if there are no cards in the deck" do
      assert_nil Card.find_or_set_current_card_for(deck: decks(:study_later))
    end
  end

  describe ".next_card_in" do
    it "finds the next card in the deck" do
      assert_equal cards(:dog), Card.next_card_in(deck: decks(:study_now))
    end

    it "sets the next card to the current card" do
      Card.next_card_in(deck: decks(:study_now))
      assert_equal "current", card_decks(:dog_study_now).status
    end

    it "sets the previously current card status to nil" do
      Card.next_card_in(deck: decks(:study_now))
      assert_nil card_decks(:cat_study_now).status
    end

    it "returns nil when there are no cards in the deck" do
      assert_nil Card.next_card_in(deck: decks(:study_later))
    end

    describe "when is_randomized is true" do
      it "does not shuffle the deck when not on the last card" do
        decks(:study_now).update(is_randomized: true)
        assert_no_changes -> { CardDeck.where(deck: decks(:study_now)).take(5) } do
          Card.next_card_in(deck: decks(:study_now))
        end
      end

      it "shuffles the deck after the last card" do
        card_decks(:cat_study_now).update(status: nil)
        card_decks(:glass_study_now).update(status: "current")
        decks(:study_now).update(is_randomized: true)

        assert_changes -> { CardDeck.where(deck: decks(:study_now)).take(5) } do
          Card.next_card_in(deck: decks(:study_now))
        end
      end
    end
  end

  describe ".previous_card_in" do
    it "returns the last card in the deck when the first card is current" do
      assert_equal cards(:glass), Card.previous_card_in(deck: decks(:study_now))
    end

    it "sets the previous card to the current card" do
      Card.previous_card_in(deck: decks(:study_now))
      assert_equal "current", card_decks(:glass_study_now).status
    end

    it "sets the previously current card status to nil" do
      Card.previous_card_in(deck: decks(:study_now))
      assert_nil card_decks(:cat_study_now).status
    end

    it "returns nil when there are no cards in the deck" do
      assert_nil Card.previous_card_in(deck: decks(:study_later))
    end
  end

  describe "#trim_text_values" do
    it "trims whitespace before saving text values" do
      card = Card.create(kana: " くだもの ", english: " fruit ", kanji: " 果物 ")
      assert_equal "fruit", card.english
      assert_equal "くだもの", card.kana
      assert_equal "果物", card.kanji

      card.update(kana: " でんわ ", english: " telephone ", kanji: " 電話 ")
      assert_equal "telephone", card.english
      assert_equal "でんわ", card.kana
      assert_equal "電話", card.kanji
    end
  end
end
