Rails.application.routes.draw do
<<<<<<< HEAD
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # idk if this works but a placeholder is needed

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check
=======
  devise_for :users

  resources :services, only: [:new, :create, :index] do
    collection do
      get :my_services   # for members
    end
    member do
      patch :approve
      patch :reject
    end
  end
>>>>>>> origin/test-david

  resources :users, only: [:index, :show]

<<<<<<< HEAD
  # Event routes
  resources :events do
    member do
      patch :toggle_publish
    end
    collection do
      get :dashboard
    end
  end


  # Resource routes
  resources :resources do
    member do
      patch :toggle_publish
    end
    collection do
      get :dashboard
    end
  end

  # Committee routes
  resources :committees do
    resources :committee_memberships, only: [ :create, :destroy ]
    member do
      get :delete
    end
  end

  # root
  root "home#index"

  # User / Auth routes
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  devise_scope :user do
    get "/users/sign_in", to: "devise/sessions#new", as: :new_user_session
    get "/users/sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  resources :users do
    member do
      get :delete
    end
  end
end
=======
  root "home#index"
end
>>>>>>> origin/test-david
