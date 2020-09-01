Rails.application.routes.draw do
  root to: "decks#index"

  resources :cards
  resources :decks
  resources :card_decks, only: [:create, :destroy]

  patch '/decks/:id/next_card', to: 'decks#next_card', as: :next_card
  patch '/card_decks/move', to: 'card_decks#move'
end
