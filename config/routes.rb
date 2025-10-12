Rails.application.routes.draw do
  # User / Auth routes
  devise_for :users, controllers: {
    seesions: 'usrs/sessions',
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  #devise_scope :user do
    #get "/users/sign_in",  to: "devise/sessions#new",     as: :new_user_session
    #get "/users/sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  #end

  # Users
  resources :users do
    member do
      get :delete
    end
    collection do
      post :bulk_update
      get  :bulk_edit
      post :reset_inactive
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

  # Service routes (needed for new_service_path, services_path, approve/reject, etc.)
  resources :services do
    collection do
      get :my_services
    end
    member do
      patch :approve
      patch :reject
    end
  end

  # Root
  root "home#index"
end