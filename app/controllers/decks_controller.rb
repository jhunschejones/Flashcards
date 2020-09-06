class DecksController < ApplicationController
  before_action :set_deck, except: [:index, :new, :create]

  def index
    @decks = Deck.includes(:card_decks).order(created_at: :desc)
  end

  def show
    @current_card = Card.find_or_set_current_card_for(deck: @deck)
    @current_card&.increment!(:review_count, touch: true)
    @all_decks = Deck.order(created_at: :desc)
    @moveable_decks = @all_decks - Array(@deck)
  end

  def new
    @deck = Deck.new
    @start_with_options = start_with_options(@deck)
  end

  def edit
    @start_with_options = start_with_options(@deck)
    @availible_decks = Deck.order(created_at: :desc).where.not(id: @deck.id)
  end

  def sort_cards
  end

  def create
    @deck = Deck.create!(deck_params)
    redirect_to deck_path(@deck)
  end

  def update
    @deck.update(deck_params)
    redirect_to deck_path(@deck)
  end

  def destroy
    @deck.destroy
    respond_to(&:js)
  end

  def take_cards
    if invalid_take_cards_info?
      flash[:notice] = "Specify the number of cards to move and one target deck"
      return redirect_to edit_deck_path(@deck)
    end

    if params[:take_from_deck_id].present?
      take_from_deck = Deck.includes(:cards).find(params[:take_from_deck_id])
      move_to_deck = @deck
    elsif params[:move_to_deck_id].present?
      take_from_deck = @deck
      move_to_deck = Deck.find(params[:move_to_deck_id])
    end

    cards_to_take = take_from_deck.cards.take(params[:number_of_cards].to_i)
    ActiveRecord::Base.transaction do
      cards_to_take.each do |card|
        # Attempt to create the new card_deck, do not raise if it already exists
        CardDeck.find_or_create_by(card: card, deck: move_to_deck)
        CardDeck.find_by(card: card, deck: take_from_deck).destroy
      end
    end
    flash[:success] = "#{cards_to_take.size} moved to '#{move_to_deck.name}'"

    redirect_to decks_path
  end

  def next_card
    next_card = Card.next_card_in(deck: @deck)
    next_card.increment!(:review_count, touch: true)
    respond_to do |format|
      format.html { redirect_to deck_path(@deck) }
      format.js { @current_card = next_card }
    end
  end

  def previous_card
    previous_card = Card.previous_card_in(deck: @deck)
    previous_card.increment!(:review_count, touch: true)
    respond_to do |format|
      format.html { redirect_to deck_path(@deck) }
      format.js {
        @current_card = previous_card
        render '/decks/next_card'
      }
    end
  end

  private

  def deck_params
    params.require(:deck).permit(:name, :start_with, :is_randomized)
  end

  def set_deck
    @deck = Deck.includes(:card_decks, :cards).find(params[:id])
  end

  def start_with_options(deck)
    valid_values = Deck::VALID_START_WITH_VALUES

    unless deck.cards.blank? || deck.cards.all? { |card| card.audio_sample.attached? }
      valid_values.delete("audio_sample")
      # flash[:notice] = "Some cards in this deck are missing an audio sample"
    end

    valid_values.map do |start_with_value|
      [start_with_value.titleize, start_with_value]
    end
  end

  def invalid_take_cards_info?
    (params[:take_from_deck_id].blank? && params[:move_to_deck_id].blank?) || (params[:take_from_deck_id].present? && params[:move_to_deck_id].present?) || params[:number_of_cards].to_i.zero?
  end
end
