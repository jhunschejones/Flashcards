Rails.application.routes.draw do
  root to: "decks#index"

  controller :sessions do
    get "login" => :new
    post "login" => :create
    delete "logout" => :destroy
  end

  get "/cards/report", to: "cards#report"
  resources :cards do
    member do
      patch :move_decks
      delete :delete_audio_sample
    end
  end

  resources :decks do
    member do
      patch :next_card, as: :next_card_in
      patch :previous_card, as: :previous_card_in
      patch :take_cards
      patch :shuffle
      get :sort_cards
      get :study
    end
  end

  resources :card_decks, only: [:create, :destroy] do
    collection do
      patch :sort
    end
  end

  %w( 404 422 500 503 ).each do |code|
    get code, to: "static_pages#error", code: code
  end
end
