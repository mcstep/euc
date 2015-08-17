require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq', constraints: User::Session::Constraint.new(:sidekiq?)

  resources :monitoring, only: [], constraints: User::Session::Constraint.new(:monitoring?) do
    collection do
      get :sidekiq
    end
  end

  root 'home#index'

  resource :session do
    member do
      post :recover
      get  :verify
      post :verify
    end
  end

  resource :registration, only: [:new, :create]
  get '/register/:code', to: 'registrations#new'

  resources :support_requests, only: [:create]

  resource :current_user do
    member do
      post :accept_airwatch_eula
      post :update_password
    end
  end

  resources :users do
    member do
      get  :impersonate
    end
    collection do
      get :unimpersonate
    end
  end
  resources :user_integrations do
    member do
      post :prolong
    end
  end
  resources :directory_prolongations, only: [:create]
  resources :invitations
  resources :domains do
    member do
      get :toggle
    end
  end
  resources :registration_codes
  resources :profiles
  resources :integrations
  resources :directories
  resources :airwatch_instances
  resources :google_apps_instances
  resources :office365_instances
  resources :horizon_instances

  scope '/api' do
    scope '/trygrid' do
      scope '/v1' do
        scope '/accounts' do
          get '/' => 'ghetto/accounts#index'
          post '/' => 'ghetto/accounts#create'
          scope '/:uuid' do
            get '/' => 'ghetto/accounts#show'
            delete '/' => 'ghetto/accounts#delete'
            put '/' => 'ghetto/accounts#update'
            post '/password_reset' => 'ghetto/accounts#reset_password'
            post '/password_change' => 'ghetto/accounts#change_password'
          end
        end
      end
    end
  end
end
