Rails.application.routes.draw do
  get 'password_reset/create'

  get 'signup/new'

  #resources :invitations
  resources :invitations do
    collection do
      get 'check_invitation'
    end
  end

  root 'home#index'

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "signup#new", :as => "sign_up"
  get "dashboard" => "home#index", :as => "dashboard"
  post "password_reset" => "password_reset#create", :as => "password_reset"

  get "toggle" => "domains#toggle", :as => "toggle"

  get 'home/index'

  get 'sessions/new'

  resources :domains
  resources :sessions
  resources :signup

  require 'sidekiq/web'
  
  class SessionAuthenticatedConstraint
    def self.matches?(request)
      !request.session[:user_id].blank?
    end
  end

  constraints(SessionAuthenticatedConstraint) do
    mount Sidekiq::Web => '/sidekiq'
  end
end
