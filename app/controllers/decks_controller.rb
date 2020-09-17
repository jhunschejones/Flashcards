class DecksController < ApplicationController
  before_action :set_deck, except: [:index, :new, :create]

  def index
    @decks = Deck.includes(:card_decks).order(created_at: :asc)
  end

  def show
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
    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to decks_path }
    end
  end

  def destroy
    @deck.destroy
    respond_to(&:js)
  end

  def take_cards
    if invalid_take_cards_info?
      flash[:notice] = "Specify the number of cards to move, target deck and difficulty"
      return redirect_to edit_deck_path(@deck)
    end

    if params[:take_from_deck_id].present?
      take_from_deck = Deck.includes(:card_decks).find(params[:take_from_deck_id])
      move_to_deck = @deck
    elsif params[:move_to_deck_id].present?
      take_from_deck = @deck
      move_to_deck = Deck.find(params[:move_to_deck_id])
    end

    cards_to_take = take_from_deck.cards.where(difficulty: params[:difficulty].to_i).take(params[:number_of_cards].to_i)
    ActiveRecord::Base.transaction(joinable: false) do
      cards_to_take.each { |card| CardDeck.find_by(deck: take_from_deck, card: card).move_to(new_deck: move_to_deck) }
    end

    flash[:success] = "#{cards_to_take.size} #{"card".pluralize(cards_to_take.size)} moved to #{move_to_deck.name}"
    redirect_to decks_path
  end

  def next_card
    next_card = @deck.next_card
    unless next_card
      show_no_matching_cards_message
      return redirect_to deck_path(@deck)
    end
    next_card.increment!(:review_count, touch: true)
    respond_to do |format|
      format.html { redirect_to deck_path(@deck) }
      format.js {
        @current_card = next_card
        @progress = @deck.progress
      }
    end
  end

  def previous_card
    previous_card = @deck.previous_card
    unless previous_card
      show_no_matching_cards_message
      return redirect_to deck_path(@deck)
    end
    previous_card.increment!(:review_count, touch: true)
    respond_to do |format|
      format.html { redirect_to deck_path(@deck) }
      format.js {
        @current_card = previous_card
        @progress = @deck.progress
        render '/decks/next_card'
      }
    end
  end

  def shuffle
    @deck.shuffle
    flash[:success] = "Deck shuffled!"
    redirect_to deck_path(@deck)
  end

  def study
    @current_card = @deck.current_card
    unless @current_card
      show_no_matching_cards_message
      return redirect_to deck_path(@deck)
    end

    @current_card.increment!(:review_count, touch: true)
    @progress = @deck.progress
  end

  private

  def deck_params
    params.require(:deck).permit(:name, :start_with, :is_randomized, :maximum_difficulty, :minimum_difficulty)
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
    (params[:take_from_deck_id].blank? && params[:move_to_deck_id].blank?) || (params[:take_from_deck_id].present? && params[:move_to_deck_id].present?) || params[:number_of_cards].to_i.zero? || params[:difficulty].to_i.zero?
  end

  def show_no_matching_cards_message
    if @deck.maximum_difficulty < @deck.minimum_difficulty
      flash[:alert] = "Deck maximum cannot be set lower than deck minimum"
    else
      flash[:notice] = "No cards in this deck have a difficulty between maximum: #{@deck.maximum_difficulty} and minimum: #{@deck.minimum_difficulty}"
    end
  end
end
