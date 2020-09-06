class DecksController < ApplicationController
  before_action :set_deck, only: [:show, :edit, :update, :destroy, :next_card, :previous_card]

  def index
    @decks = Deck.includes(:card_decks).order(created_at: :desc)
  end

  def show
    @current_card = Card.find_or_set_current_card_for(deck: @deck)
    @current_card.increment!(:review_count, touch: true)
    @all_decks = Deck.order(created_at: :desc)
    @moveable_decks = @all_decks - Array(@deck)
  end

  def new
    @deck = Deck.new
    @start_with_options = start_with_options(@deck)
  end

  def edit
    @start_with_options = start_with_options(@deck)
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
end
