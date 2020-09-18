class CardDecksController < ApplicationController
  def create
    CardDeck.create!(
      card_id: params[:card_deck][:card_id],
      deck_id: params[:card_deck][:deck_id]
    )
    head :ok
  end

  def destroy
    CardDeck.destroy(params["id"])
    head :ok
  end

  def sort
    @card_deck = CardDeck.find_by(card_id: params["card_id"], deck_id: params["deck_id"])
    @card_deck.insert_at(params[:position].to_i)
    head :ok
  end
end
