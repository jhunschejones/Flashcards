class CardsController < ApplicationController
  before_action :set_card, except: [:index, :new, :create]

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
    @card.update(card_params)
    redirect_to card_path(@card)
  end

  def destroy
    @card.destroy
    respond_to(&:js)
  end

  def move_decks
    current_deck = Deck.includes(card_decks: [:card]).find(params[:old_deck_id])
    new_deck = Deck.includes(card_decks: [:card]).find(params[:new_deck_id])

    next_card =
      ActiveRecord::Base.transaction do
        CardDeck.create_if_not_exists(card: @card, deck: new_deck)
        destroyed_card_deck = CardDeck.find_by(card: @card, deck: current_deck).destroy

        # After a card_deck is destroyed, position values cascade such that the old
        # position value should now have been re-assigned to the next card_deck. If
        # the last card was moved out of the deck we need to return nil out of this
        # transaction -- hence the safe operators after looking up the card_deck.
        current_card_deck = CardDeck.find_by(position: destroyed_card_deck.position, deck: current_deck)
        current_card_deck&.update(status: CardDeck::CURRENT_CARD)
        current_card_deck&.card
      end

    unless next_card.present?
      flash[:success] = "You finished all the cards in #{current_deck.name}!"
      return redirect_to(decks_path)
    end

    @deck = current_deck
    @current_card = next_card
    @progress = "#{@deck.position_of(card: @current_card)} / #{@deck.card_decks.size}"

    respond_to { |format| format.js { render '/decks/next_card' } }
  end

  def delete_audio_sample
    @card.audio_sample.purge
    redirect_to edit_card_path(@card)
  end

  private

  def card_params
    params.require(:card).permit(:english, :kana, :audio_sample)
  end

  def set_card
    @card = Card.includes(card_decks: [:card]).find(params[:id])
  end
end
