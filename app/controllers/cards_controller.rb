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
    @card.update(card_params)
    redirect_to card_path(@card)
  end

  def destroy
    @card.destroy
    respond_to(&:js)
  end

  def move_decks
    @deck = Deck.includes(card_decks: [:card]).find(params[:old_deck_id])
    card_deck_to_move = CardDeck.find_by(card: @card, deck: @deck)
    card_deck_to_move.move(new_deck: Deck.find(params[:new_deck_id]))

    # After a card_deck is moved position values cascade such that the old current
    # position value should now have been re-assigned to the next card_deck. If
    # the card moved was at the end of the deck, we should select the first card next.
    next_card_deck = CardDeck.find_by(position: card_deck_to_move.position, deck: @deck) || @deck.card_decks.reload.first
    next_card_deck = @deck.shuffle.card_decks.reload.first if next_card_deck&.should_shuffle?

    next_card_deck&.update(status: CardDeck::CURRENT_CARD) || begin
      flash[:success] = "You finished all the cards in #{@deck.name}!"
      return redirect_to(decks_path)
    end

    @current_card = next_card_deck.card
    @progress = "#{@deck.position_of(card: @current_card)} / #{@deck.cards.size}"
    respond_to { |format| format.js { render '/decks/next_card' } }
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
    params.require(:card).permit(:english, :kana, :kanji, :audio_sample)
  end

  def set_card
    @card = Card.includes(card_decks: [:card]).find(params[:id])
  end
end
