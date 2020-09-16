class DecksController < ApplicationController
  before_action :set_deck, except: [:index, :new, :create]

  def index
    @decks = Deck.includes(:card_decks).order(created_at: :asc)
  end

  def show
    @current_card = Card.find_or_set_current_card_for(deck: @deck)

    if @current_card.nil?
      flash[:success] = "You finished all the cards in #{@deck.name}!"
      redirect_to(decks_path)
    else
      @current_card.increment!(:review_count, touch: true)
      @progress = deck_progress
      @all_decks = Deck.order(created_at: :asc)
      @moveable_decks = @all_decks - Array(@deck)

      if @deck.is_randomized
        flash.now[:notice] = "This deck will automatically shuffle after you complete the last card."
      end
    end
  end

  def new
    @deck = Deck.new
    @start_with_options = start_with_options(@deck)
  end

  def edit
    @start_with_options = start_with_options(@deck)
    @availible_decks = Deck.order(created_at: :asc).where.not(id: @deck.id)
  end

  def sort_cards
  end

  def create
    @deck = Deck.create!(deck_params)
    flash[:success] = "#{@deck.name} was successfully created!"
    redirect_to decks_path
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
      take_from_deck = Deck.includes(:card_decks).find(params[:take_from_deck_id])
      move_to_deck = @deck
    elsif params[:move_to_deck_id].present?
      take_from_deck = @deck
      move_to_deck = Deck.find(params[:move_to_deck_id])
    end

    cards_to_take = take_from_deck.card_decks.take(params[:number_of_cards].to_i)
    ActiveRecord::Base.transaction(joinable: false) do
      cards_to_take.each { |card_deck| card_deck.move_to(new_deck: move_to_deck) }
    end
    flash[:success] = "#{cards_to_take.size} #{"card".pluralize(cards_to_take.size)} moved to #{move_to_deck.name}"

    redirect_to decks_path
  end

  def next_card
    next_card = Card.next_card_in(deck: @deck)
    next_card.increment!(:review_count, touch: true)
    respond_to do |format|
      format.html { redirect_to deck_path(@deck) }
      format.js {
        @current_card = next_card
        @progress = deck_progress
      }
    end
  end

  def previous_card
    previous_card = Card.previous_card_in(deck: @deck)
    previous_card.increment!(:review_count, touch: true)
    respond_to do |format|
      format.html { redirect_to deck_path(@deck) }
      format.js {
        @current_card = previous_card
        @progress = deck_progress
        render '/decks/next_card'
      }
    end
  end

  def shuffle
    @deck.shuffle
    flash[:success] = "Deck shuffled!"
    redirect_to edit_deck_path(@deck)
  end

  private

  def deck_params
    params.require(:deck).permit(:name, :start_with, :is_randomized)
  end

  def set_deck
    @deck = Deck.includes(card_decks: [:card]).find(params[:id])
  end

  def start_with_options(deck)
    valid_values = Deck::VALID_START_WITH_VALUES

    unless deck.cards&.all? { |card| card.audio_sample.attached? }
      valid_values = valid_values - Array("audio_sample")
    end

    unless deck.cards&.all? { |card| card.kanji.present? }
      valid_values = valid_values - Array("kanji")
    end

    valid_values.map do |start_with_value|
      [start_with_value.titleize, start_with_value]
    end
  end

  def invalid_take_cards_info?
    (params[:take_from_deck_id].blank? && params[:move_to_deck_id].blank?) || (params[:take_from_deck_id].present? && params[:move_to_deck_id].present?) || params[:number_of_cards].to_i.zero?
  end

  def deck_progress
    "#{@deck.position_of(card: @current_card)} / #{@deck.card_decks.size}"
  end
end
