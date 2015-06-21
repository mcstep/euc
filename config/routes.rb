Rails.application.routes.draw do
  root 'home#index'

  resource :session

  resources :support_requests, only: [:create]

  resources :users do
    member do
      post :update_password
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

  resource :report, only: [] do
    collection do
      get :seats
    end
  end
end
