Rails.application.routes.draw do
  get 'password_reset/create'

  get 'signup/new'

  resources :invitations

  root 'sessions#new'

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "signup#new", :as => "sign_up"
  get "dashboard" => "home#index", :as => "dashboard"
  post "password_reset" => "password_reset#create", :as => "password_reset"

  get 'home/index'

  get 'sessions/new'

  resources :users
  resources :sessions
  resources :signup

  require 'sidekiq/web'
  #mount Sidekiq::Web => '/sidekiq'
  
  class SessionAuthenticatedConstraint
    def self.matches?(request)
      !request.session[:user_id].blank?
    end
  end

  constraints(SessionAuthenticatedConstraint) do
    mount Sidekiq::Web => '/sidekiq'
  end
end
