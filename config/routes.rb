Rails.application.routes.draw do
  resources :invitations

  root 'home#index'

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "users#new", :as => "sign_up"

  get 'home/index'

  get 'sessions/new'

  resources :users
  resources :sessions
end
