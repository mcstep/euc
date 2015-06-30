Rails.application.routes.draw do
  root 'home#index'

  resource :session do
    member do
      post :recover
    end
  end

  resource :registration, only: [:new, :create]

  resources :support_requests, only: [:create]

  resource :profile do
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
  resources :invitations
  resources :domains do
    member do
      get :toggle
    end
  end
  resources :registration_codes
end
