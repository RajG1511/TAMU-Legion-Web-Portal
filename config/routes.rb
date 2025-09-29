Rails.application.routes.draw do
  # Devise routes with OmniAuth (keeps sessions so logout works)
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "devise/sessions"
  }

  # Services routes
  resources :services, only: [:new, :create, :index] do
    collection do
      get :my_services   # for members
    end
    member do
      patch :approve
      patch :reject
    end
  end

  # Users
  resources :users do
    member do
      get :delete
    end
  end

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
    resources :committee_memberships, only: [:create, :destroy]
    member do
      get :delete
    end
  end

  # Root
  root "home#index"
end