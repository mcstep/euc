Rails.application.routes.draw do
  get 'signup/new'

  resources :invitations

  root 'home#index'

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "signup#new", :as => "sign_up"

  get 'home/index'

  get 'sessions/new'

  resources :users
  resources :sessions
  resources :signup

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
