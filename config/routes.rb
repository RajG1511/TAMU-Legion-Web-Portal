Rails.application.routes.draw do
     # User / Auth routes
     devise_for :users,
       skip: [ :registrations ],
       controllers: {
         sessions: "users/sessions",
         omniauth_callbacks: "users/omniauth_callbacks"
       }

  # Users routes
  resources :users do
       member do
            get :delete
       end
    collection do
         patch :bulk_update
      get :bulk_edit
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
       member do
            get :delete
       end
    collection do 
         get :dashboard
    end
    resources :committee_memberships, only: [ :create, :destroy ]
  end

  # Service routes
  resources :services do
       member do
            patch :approve
         patch :reject
       end
    collection do
         get :dashboard
    end
  end

  get "services/dashboard", to: "services#dashboard", as: :services_dashboard

  # 🏠 Home page (public) + exec-only editor
  get "/home/edit", to: "home#edit", as: :edit_home
  patch "/home", to: "home#update", as: :home

  # 📄 Recruitment page (public) + exec-only editor
  get  "/recruitment",       to: "recruitment#index",  as: :recruitment
  get  "/recruitment/edit",  to: "recruitment#edit",   as: :edit_recruitment
  patch "/recruitment",      to: "recruitment#update", as: :update_recruitment

  # About page
  get "/about", to: "about#index", as: :about
  get "/about/edit", to: "about#edit", as: :edit_about
  patch "/about", to: "about#update", as: :update_about

  # Contact page
  get "/contact", to: "contact#index", as: :contact
  get "/contact/edit", to: "contact#edit", as: :edit_contact
  patch "/contact", to: "contact#update", as: :update_contact

  # Members page
  get "/members", to: "users#public_index", as: :members

  # Root
  root "home#index"

  # Member Center main page
  get "member_center", to: "home#member_center", as: :member_center

  # Gallery management (exec/president only)
  scope :member_center do
       post "upload_gallery",                to: "home#upload_gallery",              as: :upload_gallery
    delete "delete_gallery_photo/:photo_id", to: "home#delete_gallery_photo",       as: :delete_gallery_photo
    post   "update_caption",                to: "users#update_member_center_caption", as: :update_member_center_caption
  end

  # Login page
  get "login", to: "home#login"
end
