class CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update, :destroy, :move_decks, :delete_audio_sample]

  def index
    @cards = Card.order(created_at: :desc)
  end

  def show
  end

  def new
    @card = Card.new
    @decks = Deck.order(created_at: :desc)
  end

  def edit
    @decks = Deck.order(created_at: :desc)
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
    @card.update(card_params)
    redirect_to card_path(@card)
  end

  def destroy
    @card.destroy
    respond_to(&:js)
  end

  def move_decks
    @current_deck = Deck.find(params[:old_deck_id])
    @new_deck = Deck.find(params[:new_deck_id])

    ActiveRecord::Base.transaction do
      CardDeck.find_by(card: @card, deck_id: params[:old_deck_id]).destroy
      # Attempt to create the new card_deck, which may already exist
      CardDeck.find_or_create_by(card: @card, deck_id: params[:new_deck_id])
    end

    @current_card = Card.next_card_in(deck: @current_deck)
    return redirect_to(deck_path(@current_deck)) unless @current_card.present?

    respond_to { |format| format.js { render '/decks/next_card' } }
  end

  def delete_audio_sample
    @card.audio_sample.purge
    redirect_to edit_card_path(@card)
  end

  private

  def card_params
    params.require(:card).permit(:english, :japanese, :audio_sample)
  end

  def set_card
    @card = Card.find(params[:id])
  end
end
