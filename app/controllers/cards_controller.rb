class CardsController < ApplicationController
  before_action :set_card, except: [:index, :new, :create, :report]

  def index
    @cards = Card.includes(:card_decks).order(english: :asc)
  end

  def show
  end

  def new
    @card = Card.new
    @decks = Deck.order(created_at: :asc)
  end

  def edit
    @decks = Deck.order(created_at: :asc)
  end

  def create
    ActiveRecord::Base.transaction do
      @card = Card.create!(card_params)
      if params[:card][:deck_id].present?
        CardDeck.create!(card: @card, deck_id: params[:card][:deck_id])
      end
    end
    redirect_to card_path(@card)
  rescue ActiveRecord::RecordNotUnique
    flash[:alert] = "A card already exists for: '#{card_params[:english]}'"
    redirect_to new_card_path
  end

  def update
    # If we are updating the difficulty, the cards_to_study query may lose it's
    # place in the deck. We need to check if the new difficulty falls within the
    # decks's difficulty range, and if so move the current card marker back to
    # the last card still in range before updating this card.
    if card_params[:difficulty]
      CardDeck.where(card: @card, status: CardDeck::CURRENT_CARD).each do |card_deck|
        deck = card_deck.deck
        unless (deck.minimum_difficulty..deck.maximum_difficulty).include?(card_params[:difficulty].to_i)
          deck.previous_card
        end
      end
    end

    @card.update(card_params)
    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to card_path(@card) }
    end
  end

  def destroy
    @card.destroy
    respond_to(&:js)
  end

  def delete_audio_sample
    @card.audio_sample.purge
    redirect_to edit_card_path(@card)
  end

  def report
    @total_cards = Card.count
    @total_card_views = Card.sum(:review_count).to_i
    @cards_not_in_decks = Card.left_outer_joins(:card_decks).where(card_decks: { card_id: nil })
  end

  private

  def card_params
    params.require(:card).permit(:english, :kana, :kanji, :audio_sample, :difficulty)
  end

  def set_card
    @card = Card.includes(card_decks: [:card]).find(params[:id])
  end
end
