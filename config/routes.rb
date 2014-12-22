Rails.application.routes.draw do
  get 'password_change/check_password'

  get 'password_change/change_password'

  get 'eula/accept'

  get 'reports/stats' => "reports#potential_seats", :as => "reports_seats_stats"

  get 'support_request/create'

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
  get "forgotpassword" => "sessions#new", :as => "forgotpassword"
  get "register" => "signup#new", :as => "register"
  get "dashboard" => "home#index", :as => "dashboard"
  post "password_reset" => "password_reset#create", :as => "password_reset"
  post "support_request" => "support_request#create", :as => "support_request"
  post "extend_invitation" => "invitations#extend", :as => "extend_invitation"
  post "impersonate_user" => "invitations#impersonate", :as => "impersonate_user"
  post "unimpersonate" => "invitations#unimpersonate", :as => "unimpersonate"
  post "eula" => "eula#create", :as => "eula"
  get "invitation_search" => "invitations#search", :as => "invitation_search"

  post "change_password" => "password_change#change_password", :as => "change_password"
  
  get "toggle" => "domains#toggle", :as => "toggle"
  get "toggle_airwatch" => "eula#toggle_airwatch", :as => "toggle_airwatch"

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
