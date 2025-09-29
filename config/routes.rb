Rails.application.routes.draw do
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

  resources :users, only: [:index, :show]

  root "home#index"
end