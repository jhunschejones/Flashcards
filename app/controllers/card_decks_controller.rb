class CardDecksController < ApplicationController
  def create
    CardDeck.create!(
      card_id: params[:card_deck][:card_id],
      deck_id: params[:card_deck][:deck_id]
    )
  end

  def destroy
    CardDeck.destroy(params["id"])
  end

  def move
    @card_deck = CardDeck.find_by(card_id: params["card_id"], deck_id: params["deck_id"])
    @card_deck.insert_at(params[:position].to_i)
  end
end
