require 'test_helper'

# bundle exec ruby -Itest test/controllers/cards_controller_test.rb
class CardsControllerTest < ActionDispatch::IntegrationTest
  describe "GET index" do
    describe "when no user is logged in" do
      it "redirects to the login page" do
        get cards_path
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "shows the all cards page" do
        get cards_path
        assert_response :success
        assert_select "div.all-cards-container"
      end
    end
  end

  describe "GET show" do
    describe "when no user is logged in" do
      it "redirects to the login page" do
        get card_path(cards(:cat))
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "shows the card page" do
        get card_path(cards(:cat))
        assert_response :success
        assert_select "div.card-details-card"
        assert_select "div.english-text", cards(:cat).english
        assert_select "div.kana-text", cards(:cat).kana
        assert_select "div.kanji-text", cards(:cat).kanji
      end
    end
  end

  describe "GET new" do
    describe "when no user is logged in" do
      it "redirects to the login page" do
        get new_card_path
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "shows the new card page" do
        get new_card_path
        assert_response :success
        assert_select "h2.title", "New card"
      end
    end
  end

  describe "GET edit" do
    describe "when no user is logged in" do
      it "redirects to the login page" do
        get edit_card_path(cards(:cat))
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "shows the edit card page" do
        get edit_card_path(cards(:cat))
        assert_response :success
        assert_select "h2.title", "Edit card"
        assert_select "input" do
          assert_select "[value=?]", cards(:cat).english
          assert_select "[value=?]", cards(:cat).kana
          assert_select "[value=?]", cards(:cat).kanji
        end
      end
    end
  end

  describe "POST create" do
    describe "when no user is logged in" do
      it "does not create a new card" do
        assert_no_difference "Card.count" do
          post cards_path, params: { card: { english: "thanks", kana: "どうも" } }
        end
      end

      it "redirects to the login page" do
        post cards_path, params: { card: { english: "thanks", kana: "どうも" } }
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "creates a new card" do
        assert_difference "Card.count", 1 do
          post cards_path, params: { card: { english: "thanks", kana: "どうも" } }
        end
      end

      it "redirects to the card show page" do
        post cards_path, params: { card: { english: "thanks", kana: "どうも" } }
        assert_redirected_to card_path(Card.last)
        follow_redirect!
        assert_select "div.card-details-card"
        assert_select "div.english-text", "thanks"
        assert_select "div.kana-text", "どうも"
        assert_select "div.kanji-text", ""  # No kanji included
      end

      describe "when a deck is specified" do
        it "creates a card_deck record" do
          assert_difference "CardDeck.count", 1 do
            post cards_path, params: { card: { english: "thanks", kana: "どうも", deck_id: decks(:study_now).id } }
          end
          assert_equal "thanks", CardDeck.last.card.english
          assert_equal decks(:study_now), CardDeck.last.deck
        end
      end

      describe "when the card already exists" do
        it "does not create the new card" do
          assert_no_difference "Card.count" do
            post cards_path, params: { card: { english: cards(:cat).english, kana: cards(:cat).kana } }
          end
        end

        it "redirects to new card page with a message" do
          post cards_path, params: { card: { english: cards(:cat).english, kana: cards(:cat).kana } }
          assert_redirected_to new_card_path
          assert_equal "A card already exists for: 'cat'", flash[:alert]
        end
      end
    end
  end

  describe "PATCH update" do
    describe "when no user is logged in" do
      it "does not update the card record" do
        assert_no_changes -> { Card.find(cards(:foot).id).english } do
          patch card_path(cards(:foot)), params: { card: { english: "foot; leg" } }
        end
      end

      it "redirects to the login page" do
        patch card_path(cards(:foot)), params: { card: { english: "foot; leg" } }
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      describe "for html request" do
        it "updates the card record" do
          assert_changes -> { Card.find(cards(:foot).id).english } do
            patch card_path(cards(:foot)), params: { card: { english: "foot; leg" } }
          end
          assert_equal "foot; leg", Card.find(cards(:foot).id).english
        end

        it "redirects to the card show page" do
          patch card_path(cards(:foot)), params: { card: { english: "foot; leg" } }
          assert_redirected_to card_path(cards(:foot))
          follow_redirect!
          assert_select "div.card-details-card"
          assert_select "div.english-text", "foot; leg"
          assert_select "div.kana-text", cards(:foot).kana
          assert_select "div.kanji-text", cards(:foot).kanji
        end
      end

      describe "for json request" do
        it "updates the card record" do
          assert_changes -> { Card.find(cards(:foot).id).english } do
            patch card_path(cards(:foot), format: :json), params: { card: { english: "foot; leg" } }
          end
          assert_response :ok
          assert_equal "foot; leg", Card.find(cards(:foot).id).english
        end

        describe "when decks are not affected by the update" do
          it "does not move the current card pointer" do
            assert_no_changes -> { CardDeck.find_by(deck: decks(:study_now), status: "current") } do
              patch card_path(cards(:cat), format: :json), params: { card: { difficulty: 3 } }
            end
            assert_equal "current", card_decks(:cat_study_now).status
          end
        end

        describe "when update would cause current card to be lost" do
          before do
            decks(:study_now).update(minimum_difficulty: 3)
          end

          it "moves the current card pointer back" do
            assert_changes -> { CardDeck.find_by(deck: decks(:study_now), status: "current") } do
              patch card_path(cards(:cat), format: :json), params: { card: { difficulty: 1 } }
            end
            assert_equal "current", card_decks(:glass_study_now).status
          end
        end
      end
    end
  end

  describe "DELETE destroy" do
    describe "when no user is logged in" do
      it "does not destroy the card record" do
        assert_no_difference "Card.count" do
          delete card_path(cards(:cat), format: :js)
        end
      end

      it "redirects to the login page" do
        delete card_path(cards(:cat), format: :js)
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "destroys the card record" do
        assert_difference "Card.count", -1 do
          delete card_path(cards(:cat), format: :js)
        end
      end

      it "returns expected JS to modify the UI" do
        delete card_path(cards(:cat), format: :js)
        assert_match /var deletedCard = document.querySelector\('\[data-card-id=\"#{cards(:cat).id}\"\]'\);/, response.body
      end
    end
  end

  describe "DELETE delete_audio_sample" do
    before do
      cards(:foot).audio_sample.attach(io: File.open('./test/fixtures/files/1018.mp3'), filename: '1018.mp3')
    end

    describe "when no user is logged in" do
      it "does not delete the audio sample for the card" do
        assert_no_changes -> { Card.find(cards(:foot).id).audio_sample.attached? } do
          delete delete_audio_sample_card_path(cards(:foot))
        end
      end

      it "redirects to the login page" do
        delete delete_audio_sample_card_path(cards(:foot))
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "deletes the audio sample for the card" do
        assert_changes -> { Card.find(cards(:foot).id).audio_sample.attached? } do
          delete delete_audio_sample_card_path(cards(:foot))
        end
      end

      it "redirects to the edit card page" do
        delete delete_audio_sample_card_path(cards(:foot))
        assert_redirected_to edit_card_path(cards(:foot))
      end
    end
  end

  describe "GET report" do
    describe "when no user is logged in" do
      it "redirects to the login page" do
        get cards_report_path
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "loads the card report page" do
        get cards_report_path
        assert_response :success
        assert_select "h2.title", "Cards report"
      end

      it "lists only cards not in decks" do
        card_decks(:glass_study_now).destroy
        get cards_report_path
        assert_select "h2.title", "Cards not in decks"
        # 1 row for the card not in a deck and 1 for the header
        assert_select "table.cards-list tr", count: 2
        assert_select "td", cards(:glass).english
      end
    end
  end
end
