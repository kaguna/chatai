Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Chat Stream routes for Turbo Stream
  resources :chats, only: [ :show, :create, :update ]
  resources :conversations, only: [ :index, :show, :create, :destroy ] do
    post :create_conversation
    post :send_message
    get :get_messages
  end

  # Home routes
  post "create_conversation", to: "home#create_conversation"

  # Defines the root path route ("/")
  root "home#index"
end
