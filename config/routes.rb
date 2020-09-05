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

  patch '/card/:id/move_decks', to: 'cards#move_decks', as: :move_decks
  delete '/card/:id/delete_audio_sample', to: 'cards#delete_audio_sample', as: :delete_audio_sample
  patch '/decks/:id/next_card', to: 'decks#next_card', as: :next_card
  patch '/card_decks/sort', to: 'card_decks#sort'

  %w( 404 422 500 503 ).each do |code|
    get code, :to => "static_pages#error", :code => code
  end
end
