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
