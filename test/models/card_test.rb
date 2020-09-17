require 'test_helper'

# bundle exec ruby -Itest test/models/card_test.rb
class CardTest < ActiveSupport::TestCase
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
