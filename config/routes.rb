Rails.application.routes.draw do
  root to: "decks#index"

  controller :sessions do
    get "login" => :new
    post "login" => :create
    delete "logout" => :destroy
  end

  resources :cards
  resources :decks
  resources :card_decks, only: [:create, :destroy]

  patch '/decks/:id/next_card', to: 'decks#next_card', as: :next_card
  patch '/card_decks/move', to: 'card_decks#move'

  %w( 404 422 500 503 ).each do |code|
    get code, :to => "static_pages#error", :code => code
  end
end
