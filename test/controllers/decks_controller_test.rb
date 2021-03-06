require 'test_helper'

# bundle exec ruby -Itest test/controllers/decks_controller_test.rb
class DecksControllerTest < ActionDispatch::IntegrationTest
  describe "GET index" do
    describe "when no user is logged in" do
      it "redirects to the login page" do
        get decks_path
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "shows the all decks page" do
        get decks_path
        assert_response :success
        assert_select "div.all-decks-container"
      end
    end
  end

  describe "GET show" do
    describe "when no user is logged in" do
      it "redirects to the login page" do
        get deck_path(decks(:study_now))
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "shows the deck page with difficulty settings" do
        get deck_path(decks(:study_now))
        assert_response :success
        assert_select "h1.deck-name", decks(:study_now).name
        assert_select "button.maximum-difficulty", count: 5
        assert_select "button.minimum-difficulty", count: 5
      end
    end
  end

  describe "GET new" do
    describe "when no user is logged in" do
      it "redirects to the login page" do
        get new_deck_path
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "shows the new deck page" do
        get new_deck_path
        assert_response :success
        assert_select "h2.title", "New deck"
      end

      it "shows all options for the front of cards" do
        get new_deck_path
        assert_select "option", "English"
        assert_select "option", "Kana"
        assert_select "option", "Audio Sample"
      end
    end
  end

  describe "GET edit" do
    describe "when no user is logged in" do
      it "redirects to the login page" do
        get edit_deck_path(decks(:study_now))
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "shows the edit deck page" do
        get edit_deck_path(decks(:study_now))
        assert_response :success
        assert_select "h2.title", "Edit deck"
        assert_select "input" do
          assert_select "[value=?]", decks(:study_now).name
        end
      end

      it "shows options for the front of cards" do
        get edit_deck_path(decks(:study_now))
        assert_select "option", "English"
        assert_select "option", "Kana"
        # At least one card in the deck doesn't have an audio sample, so don't show that option
        assert_select "option", text: "Audio Sample", count: 0
      end
    end
  end

  describe "GET sort_cards" do
    describe "when no user is logged in" do
      it "redirects to the login page" do
        get sort_cards_deck_path(decks(:study_now))
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "shows page for sorting all the cards in the deck" do
        get sort_cards_deck_path(decks(:study_now))
        assert_response :success
        assert_select "h2.title", "Re-order cards in deck"
        decks(:study_now).cards.each do |card|
          assert_select "td", card.english
        end
      end
    end
  end

  describe "POST create" do
    describe "when no user is logged in" do
      it "does not create a new deck" do
        assert_no_difference "Deck.count" do
          post decks_path, params: { deck: { name: "Everyday words", start_with: "audio_sample" } }
        end
      end

      it "redirects to the login page" do
        post decks_path, params: { deck: { name: "Everyday words", start_with: "audio_sample" } }
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "creates a new deck" do
        assert_difference "Deck.count", 1 do
          post decks_path, params: { deck: { name: "Everyday words", start_with: "audio_sample" } }
        end
      end

      it "redirects to the decks page with message" do
        post decks_path, params: { deck: { name: "Everyday words", start_with: "audio_sample" } }
        assert_redirected_to decks_path
        assert_equal "Everyday words was successfully created!", flash[:success]
      end
    end
  end

  describe "PATCH update" do
    describe "when no user is logged in" do
      it "does not update the deck record" do
        assert_no_changes -> { Deck.find(decks(:study_now).id).name } do
          patch deck_path(decks(:study_now)), params: { deck: { name: "JLPT Review" } }
        end
      end

      it "redirects to the login page" do
        patch deck_path(decks(:study_now)), params: { deck: { name: "JLPT Review" } }
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      describe "for json request" do
        it "updates the deck record" do
          assert_changes -> { Deck.find(decks(:study_now).id).name } do
            patch deck_path(decks(:study_now), format: :json), params: { deck: { name: "JLPT Review" } }
          end
          assert_response :ok
          assert_equal "JLPT Review", Deck.find(decks(:study_now).id).name
        end
      end

      describe "for html request" do
        it "updates the deck record" do
          assert_changes -> { Deck.find(decks(:study_now).id).name } do
            patch deck_path(decks(:study_now)), params: { deck: { name: "JLPT Review" } }
          end
          assert_equal "JLPT Review", Deck.find(decks(:study_now).id).name
        end

        it "redirects to the decks page" do
          patch deck_path(decks(:study_now)), params: { deck: { name: "JLPT Review" } }
          assert_redirected_to decks_path
          follow_redirect!
          assert_select "div.all-decks-container"
        end
      end
    end
  end

  describe "DELETE destroy" do
    describe "when no user is logged in" do
      it "does not destroy the deck record" do
        assert_no_difference "Deck.count" do
          delete deck_path(decks(:study_now), format: :js)
        end
      end

      it "redirects to the login page" do
        delete deck_path(decks(:study_now), format: :js)
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "destroys the deck record" do
        assert_difference "Deck.count", -1 do
          delete deck_path(decks(:study_now), format: :js)
        end
      end

      it "returns expected JS to modify the UI" do
        delete deck_path(decks(:study_now), format: :js)
        assert_match /var deletedDeck = document.querySelector\(\".deck-id-#{decks(:study_now).id}\"\);/, response.body
      end
    end
  end

  describe "PATCH take_cards" do
    describe "when no user is logged in" do
      it "no cards are changed" do
        assert_no_difference "CardDeck.where(deck: decks(:study_now)).count" do
          patch take_cards_deck_path(decks(:study_later)), params: { take_from_deck_id: decks(:study_now).id, number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
        end
      end

      it "redirects to the login page" do
        patch take_cards_deck_path(decks(:study_later)), params: { take_from_deck_id: decks(:study_now).id, number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      describe "when taking from other deck" do
        it "removes the cards from the other deck" do
          assert_difference "CardDeck.where(deck: decks(:study_now)).count", -5 do
            patch take_cards_deck_path(decks(:study_later)), params: { take_from_deck_id: decks(:study_now).id, number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
          end
        end

        it "adds the cards to the current deck" do
          assert_difference "CardDeck.where(deck: decks(:study_later)).count", 5 do
            patch take_cards_deck_path(decks(:study_later)), params: { take_from_deck_id: decks(:study_now).id, number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
          end
        end

        it "redirects to decks page with message" do
          patch take_cards_deck_path(decks(:study_later)), params: { take_from_deck_id: decks(:study_now).id, number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
          assert_redirected_to decks_path
          assert_equal "5 cards moved to Study Later", flash[:success]
        end
      end

      describe "when moving to other deck" do
        it "removes the cards from the current deck" do
          assert_difference "CardDeck.where(deck: decks(:study_now)).count", -5 do
            patch take_cards_deck_path(decks(:study_now)), params: { move_to_deck_id: decks(:study_later).id, number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
          end
        end

        it "adds the cards to the other deck" do
          assert_difference "CardDeck.where(deck: decks(:study_later)).count", 5 do
            patch take_cards_deck_path(decks(:study_now)), params: { move_to_deck_id: decks(:study_later).id, number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
          end
        end

        it "redirects to decks path with message" do
          patch take_cards_deck_path(decks(:study_now)), params: { move_to_deck_id: decks(:study_later).id, number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
          assert_redirected_to decks_path
          assert_equal "5 cards moved to Study Later", flash[:success]
        end

        describe "when a card already exists in other deck" do
          before do
            CardDeck.create(deck: decks(:study_later), card: cards(:cat))
          end

          it "removes the cards from the current deck" do
            assert_difference "CardDeck.where(deck: decks(:study_now)).count", -5 do
              patch take_cards_deck_path(decks(:study_now)), params: { move_to_deck_id: decks(:study_later).id, number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
            end
          end

          it "adds only the non-duplicate cards to the other deck" do
            assert_difference "CardDeck.where(deck: decks(:study_later)).count", 4 do
              patch take_cards_deck_path(decks(:study_now)), params: { move_to_deck_id: decks(:study_later).id, number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
            end
          end

          it "redirects to decks path with message" do
            patch take_cards_deck_path(decks(:study_now)), params: { move_to_deck_id: decks(:study_later).id, number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
            assert_redirected_to decks_path
            assert_equal "5 cards moved to Study Later", flash[:success]
          end
        end

        describe "when more cards are requested than exist" do
          it "removes all the cards from the current deck" do
            assert_difference "CardDeck.where(deck: decks(:study_now)).count", -12 do
              patch take_cards_deck_path(decks(:study_now)), params: { move_to_deck_id: decks(:study_later).id, number_of_cards: 50, maximum_difficulty: 5, minimum_difficulty: 1 }
            end
          end

          it "adds all the cards to the other deck" do
            assert_difference "CardDeck.where(deck: decks(:study_later)).count", 12 do
              patch take_cards_deck_path(decks(:study_now)), params: { move_to_deck_id: decks(:study_later).id, number_of_cards: 50, maximum_difficulty: 5, minimum_difficulty: 1 }
            end
          end

          it "redirects to decks path with message" do
            patch take_cards_deck_path(decks(:study_now)), params: { move_to_deck_id: decks(:study_later).id, number_of_cards: 50, maximum_difficulty: 5, minimum_difficulty: 1 }
            assert_redirected_to decks_path
            assert_equal "12 cards moved to Study Later", flash[:success]
          end
        end
      end

      describe "with invalid params" do
        it "redirects to the edit deck path when too many decks are specified" do
          assert_no_difference "CardDeck.where(deck: decks(:study_now)).count" do
            patch take_cards_deck_path(decks(:study_now)), params: { move_to_deck_id: decks(:study_later).id, take_from_deck_id: decks(:study_now).id, number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
          end
          assert_redirected_to edit_deck_path(decks(:study_now))
        end

        it "redirects to the edit deck path when too few decks are specified" do
          assert_no_difference "CardDeck.where(deck: decks(:study_now)).count" do
            patch take_cards_deck_path(decks(:study_now)), params: { number_of_cards: 5, maximum_difficulty: 5, minimum_difficulty: 1 }
          end
          assert_redirected_to edit_deck_path(decks(:study_now))
        end

        it "redirects to the edit deck path when no card count is specified" do
          assert_no_difference "CardDeck.where(deck: decks(:study_now)).count" do
            patch take_cards_deck_path(decks(:study_now)), params: { move_to_deck_id: decks(:study_later).id, maximum_difficulty: 5, minimum_difficulty: 1 }
          end
          assert_redirected_to edit_deck_path(decks(:study_now))
        end
      end
    end
  end

  describe "PATCH next_card" do
    describe "when no user is logged in" do
      it "no card deck records are updated" do
        assert_no_changes -> { CardDeck.find_by(card: cards(:cat), deck: decks(:study_now)).status } do
          patch next_card_in_deck_path(decks(:study_now), format: :js)
        end
      end

      it "redirects to the login page" do
        patch next_card_in_deck_path(decks(:study_now), format: :js)
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "sets the next card as the current card" do
        patch next_card_in_deck_path(decks(:study_now), format: :js)
        assert_nil card_decks(:cat_study_now).status
        assert_equal "current", card_decks(:dog_study_now).status
      end

      it "returns JS to update the page" do
        patch next_card_in_deck_path(decks(:study_now), format: :js)
        assert_response :success
        assert_match /englishText.innerHTML = \"#{cards(:dog).english}\"/, response.body
      end

      describe "when the current card is at the end of the deck" do
        before do
          card_decks(:cat_study_now).update(status: nil)
          card_decks(:glass_study_now).update(status: "current")
        end

        it "returns the first card in the deck" do
          assert_equal "current", card_decks(:glass_study_now).status
          patch next_card_in_deck_path(decks(:study_now), format: :js)
          assert_equal "current", card_decks(:cat_study_now).reload.status
          assert_match /englishText.innerHTML = \"#{cards(:cat).english}\"/, response.body
        end

        describe "when the deck is set to auto-shuffle" do
          before do
            decks(:study_now).update(is_randomized: true)
            decks(:study_now).reload
          end

          it "shuffles the deck" do
            assert decks(:study_now).is_randomized
            assert_equal "current", card_decks(:glass_study_now).status

            assert_changes -> { CardDeck.where(deck_id: decks(:study_now).id).take(5) } do
              patch next_card_in_deck_path(decks(:study_now), format: :js)
            end
          end

          it "returns the next card" do
            patch next_card_in_deck_path(decks(:study_now), format: :js)
            first_card = decks(:study_now).reload.cards_to_study.first
            assert_match /englishText.innerHTML = \"#{first_card.english}\"/, response.body
          end
        end
      end
    end
  end

  describe "PATCH previous_card" do
    describe "when no user is logged in" do
      it "no card deck records are updated" do
        assert_no_changes -> { CardDeck.find_by(card: cards(:cat), deck: decks(:study_now)).status } do
          patch previous_card_in_deck_path(decks(:study_now), format: :js)
        end
      end

      it "redirects to the login page" do
        patch previous_card_in_deck_path(decks(:study_now), format: :js)
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "sets the previous card as the current card" do
        patch previous_card_in_deck_path(decks(:study_now), format: :js)
        assert_nil card_decks(:cat_study_now).status
        assert_equal "current", card_decks(:glass_study_now).status
      end

      it "returns JS to update the page" do
        patch previous_card_in_deck_path(decks(:study_now), format: :js)
        assert_response :success
        assert_match /englishText.innerHTML = \"#{cards(:glass).english}\"/, response.body
      end
    end
  end

  describe "PATCH shuffle" do
    describe "when no user is logged in" do
      it "does not shuffle the deck" do
        assert_no_changes -> { CardDeck.where(deck: decks(:study_now)).take(5) } do
          patch shuffle_deck_path(decks(:study_now))
        end
      end

      it "redirects to the login page" do
        patch shuffle_deck_path(decks(:study_now))
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "shuffles the deck" do
        assert_changes -> { CardDeck.where(deck: decks(:study_now)).take(5) } do
          patch shuffle_deck_path(decks(:study_now))
        end
      end

      it "redirects to deck page with message" do
        patch shuffle_deck_path(decks(:study_now))
        assert_redirected_to deck_path(decks(:study_now))
        assert_equal "Deck shuffled!", flash[:success]
      end
    end
  end
end
