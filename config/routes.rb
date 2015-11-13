require 'sidekiq/web'

Rails.application.routes.draw do
  constraints User::Session::Constraint.new(:sidekiq?) do
    mount Sidekiq::Web => '/sidekiq'
  end

  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end

  namespace :api do
    api_version(module: "V1", path: {value: "v1"}, header: {name: "X-VERSION", value: "1"}) do
      resources :users do
        member do
          post :recover
        end
      end
      resources :user_integrations do
        member do
          post  :toggle
        end
      end
      resources :invitations
      resources :nominations do
        member do
          # approve is done via edit/update
          post :decline
        end
      end
      resources :directory_prolongations, only: [:create]
      resources :reporting, only: [] do
        collection do
          get :users
          get :opportunities
        end
      end
      resources :support_requests
      resources :domains
      resources :registration_codes
      resources :airwatch_instances
      resources :blue_jeans_instances
      resources :box_instances
      resources :directories
      resources :google_apps_instances
      resources :horizon_instances
      resources :office365_instances
      resources :salesforce_instances
      resources :integrations
      resources :profiles
    end
  end

  resources :monitoring, only: [] do
    collection do
      get :sidekiq
    end
  end

  root 'home#index'
  get 'home/root', to: 'home#root', as: :root_dashboard

  resource :session do
    member do
      post :recover
    end
  end
  get '/log_in', to: 'sessions#new'

  resource :registration, only: [:new, :create] do
    member do
      get :suggest_company
    end
  end
  get '/register(/:code)', to: 'registrations#new'

  resources :support_requests, only: [:create]

  resource :current_user do
    member do
      get  :services
      post :accept_airwatch_eula
      post :update_password
    end
  end

  resources :users do
    resource :verification
    member do
      get  :impersonate
      post :recover
    end
    collection do
      get :unimpersonate
    end
  end
  resources :user_integrations do
    member do
      get  :toggle
    end
  end
  resources :directory_prolongations, only: [:new, :create]
  resources :invitations do
    member do
      get :refresh_opportunity
      get :clean_opportunity
    end
  end
  resources :reporting, only: [] do
    collection do
      get :users
      post :users
      get :opportunities
      post :opportunities
    end
  end
  resources :domains do
    member do
      get :toggle
    end
  end
  resources :nominations do
    member do
      # approve is done thru edit/update
      post :decline
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
  resources :blue_jeans_instances
  resources :salesforce_instances
  resources :box_instances
  resources :deliveries

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
