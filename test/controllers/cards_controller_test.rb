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

  describe "PATCH move_decks" do
    describe "when no user is logged in" do
      it "does not move the card" do
        assert_no_changes -> { CardDeck.where(card: cards(:cat)) } do
          patch move_decks_card_path(cards(:cat), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
        end
      end

      it "redirects to the login page" do
        patch move_decks_card_path(cards(:cat), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
        assert_redirected_to login_path
      end
    end

    describe "when a user is logged in" do
      before do
        login_as(users(:carl))
      end

      it "removes the card from the old deck" do
        assert_difference "CardDeck.where(card: cards(:cat), deck: decks(:study_now)).count", -1 do
          patch move_decks_card_path(cards(:cat), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
        end
      end

      it "adds the card to the new deck" do
        assert_difference "CardDeck.where(card: cards(:cat), deck: decks(:study_later)).count", 1 do
          patch move_decks_card_path(cards(:cat), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
        end
      end

      it "sets the next card in the deck as the new current card" do
        assert_equal card_decks(:cat_study_now), CardDeck.find_or_set_current_card_deck(deck: decks(:study_now))
        patch move_decks_card_path(cards(:cat), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
        assert_equal card_decks(:dog_study_now), CardDeck.find_or_set_current_card_deck(deck: decks(:study_now))
      end

      it "returns expected JS to update the page" do
        patch move_decks_card_path(cards(:cat), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
        assert_match /englishText.innerHTML = \"#{cards(:dog).english}\"/, response.body
      end

      describe "when the card is already in the new deck" do
        before do
          CardDeck.create(deck: decks(:study_later), card: cards(:cat))
        end

        it "removes the card from the old deck" do
          assert_difference "CardDeck.where(card: cards(:cat), deck: decks(:study_now)).count", -1 do
            patch move_decks_card_path(cards(:cat), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
          end
        end

        it "does not create a duplicate card_deck record" do
          assert_no_difference "CardDeck.where(card: cards(:cat), deck: decks(:study_later)).count" do
            patch move_decks_card_path(cards(:cat), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
          end
        end
      end

      describe "when the card moved is at the end of the deck" do
        before do
          card_decks(:cat_study_now).update(status: nil)
          card_decks(:glass_study_now).update(status: "current")
        end

        it "returns the first card in the deck" do
          assert_equal "current", card_decks(:glass_study_now).status
          patch move_decks_card_path(cards(:glass), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
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
              patch move_decks_card_path(cards(:glass), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
            end
          end

          it "returns the next card" do
            patch move_decks_card_path(cards(:glass), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
            first_card = decks(:study_now).reload.cards.first
            assert_match /englishText.innerHTML = \"#{first_card.english}\"/, response.body
          end

          it "returns an alert telling the user the deck was shuffled" do
            patch move_decks_card_path(cards(:glass), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
            assert_match /alert\(\"The deck was automatically shuffled!\"\);/, response.body
          end
        end
      end

      describe "when there are no more cards in the current deck" do
        before do
          CardDeck.where.not(id: card_decks(:cat_study_now).id).where(deck: decks(:study_now)).destroy_all
        end

        it "redirects to the decks path with message" do
          patch move_decks_card_path(cards(:cat), format: :js), params: { old_deck_id: decks(:study_now).id, new_deck_id: decks(:study_later).id }
          assert_redirected_to decks_path
          assert_equal "You finished all the cards in Study Now!", flash[:success]
        end
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
