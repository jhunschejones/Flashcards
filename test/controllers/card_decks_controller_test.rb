require 'test_helper'

# bundle exec ruby -Itest test/controllers/card_decks_controller_test.rb
class CardDecksControllerTest < ActionDispatch::IntegrationTest
  describe "POST create" do
    describe "when no user is logged in" do
      it "does not create a new card_deck record" do
        assert_no_difference "CardDeck.count" do
          post card_decks_path, params: { card_deck: { card_id: cards(:cat).id, deck_id: decks(:study_later).id } }
        end
      end

      it "redirects to the login page" do
        post card_decks_path, params: { card_deck: { card_id: cards(:cat).id, deck_id: decks(:study_later).id } }
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "creates a new card_deck record" do
        assert_difference "CardDeck.count", 1 do
          post card_decks_path, params: { card_deck: { card_id: cards(:cat).id, deck_id: decks(:study_later).id } }
        end
      end
    end
  end

  describe "DELETE destroy" do
    describe "when no user is logged in" do
      it "does not destroy the card_deck record" do
        assert_no_difference "CardDeck.count" do
          delete card_deck_path(card_decks(:cat_study_now), format: :js)
        end
      end

      it "redirects to the login page" do
        delete card_deck_path(card_decks(:cat_study_now), format: :js)
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "destroys the card_deck record" do
        assert_difference "CardDeck.count", -1 do
          delete card_deck_path(card_decks(:cat_study_now), format: :js)
        end
      end
    end
  end

  describe "PATCH sort" do
    describe "when no user is logged in" do
      it "does not change the card_deck record" do
        assert_no_changes -> { CardDeck.find(card_decks(:cat_study_now).id).position } do
          patch sort_card_decks_path(card_decks(:cat_study_now), format: :js), params: { card_id: cards(:cat).id, deck_id: decks(:study_now).id, position: 2 }
        end
      end

      it "redirects to the login page" do
        patch sort_card_decks_path(card_decks(:cat_study_now), format: :js), params: { card_id: cards(:cat).id, deck_id: decks(:study_now).id, position: 2 }
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "updates the card_deck position" do
        assert_changes -> { CardDeck.find(card_decks(:cat_study_now).id).position } do
          patch sort_card_decks_path(card_decks(:cat_study_now), format: :js), params: { card_id: cards(:cat).id, deck_id: decks(:study_now).id, position: 2 }
        end
      end
    end
  end
end
