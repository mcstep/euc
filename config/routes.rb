Rails.application.routes.draw do
  root 'home#index'

  get 'dashboard' => 'home#index', :as => 'dashboard'
  get 'eula/accept'
  get 'forgotpassword' => 'sessions#new', :as => 'forgotpassword'
  get 'home/index'
  get 'invitation_search' => 'invitations#search', :as => 'invitation_search'
  get 'log_in' => 'sessions#new', :as => 'log_in'
  get 'log_out' => 'sessions#destroy', :as => 'log_out'
  get 'password_change/change_password'
  get 'password_change/check_password'
  get 'password_reset/create'
  get 'register' => 'signup#new', :as => 'register'
  get 'register/:reg_code', to: 'signup#reg_code', :as => 'registration_code_signup'
  get 'reports/stats' => 'reports#potential_seats', :as => 'reports_seats_stats'
  get 'sessions/new'
  get 'signup/new'
  get 'support_request/create'
  get 'toggle' => 'domains#toggle', :as => 'toggle'
  get 'toggle_airwatch' => 'eula#toggle_airwatch', :as => 'toggle_airwatch'
  post 'change_password' => 'password_change#change_password', :as => 'change_password'
  post 'edit_profile' => 'users#edit_profile', :as => 'edit_profile'
  post 'eula' => 'eula#create', :as => 'eula'
  post 'extend_invitation' => 'invitations#extend', :as => 'extend_invitation'
  post 'impersonate_user' => 'invitations#impersonate', :as => 'impersonate_user'
  post 'password_reset' => 'password_reset#create', :as => 'password_reset'
  post 'support_request' => 'support_request#create', :as => 'support_request'
  post 'unimpersonate' => 'invitations#unimpersonate', :as => 'unimpersonate'

  resources :domains
  resources :reg_codes
  resources :sessions
  resources :signup
  resources :users

  resources :invitations do
    collection do
      get 'check_invitation'
    end

    get 'user' => 'users#show'
    get 'user/edit' => 'users#edit'
  end

  require 'sidekiq/web'

  class SessionAuthenticatedConstraint
    def self.matches?(request)
      !request.session[:user_id].blank?
    end
  end

  constraints(SessionAuthenticatedConstraint) do
    mount Sidekiq::Web => '/sidekiq'
  end

  scope '/api' do
    scope '/trygrid' do
      scope '/v1' do
        scope '/accounts' do
          get '/' => 'api_accounts#index'
          post '/' => 'api_accounts#create'
          scope '/:uuid' do
            get '/' => 'api_accounts#show'
            delete '/' => 'api_accounts#delete'
            put '/' => 'api_accounts#update'
            post '/password_reset' => 'api_accounts#reset_password'
            post '/password_change' => 'api_accounts#change_password'
          end
        end
      end
    end
  end
end
