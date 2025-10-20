class HomeController < ApplicationController
     # Make sure only signed-in members can hit these, then fetch the shared user
     before_action :require_member!, only: [ :member_center, :upload_gallery, :delete_gallery_photo ]
  before_action :set_shared_user, only: [ :member_center, :upload_gallery, :delete_gallery_photo ]

  # Only exec/president can edit or update the homepage
  before_action :require_exec!, only: [ :edit, :update ]

  def edit
       @sections = HomePageStore.read
  end

  def update
       inputs = HomePageStore::SECTION_KEYS.to_h { |key| [ key, params.dig(:home_page, key) ] }
       HomePageStore.save_all!(inputs: inputs, user: current_user)
       redirect_to root_path, notice: "Home page updated successfully."
     rescue ActiveRecord::RecordInvalid => e
          flash.now[:alert] = e.record.errors.full_messages.to_sentence
       @sections = HomePageStore.read
       render :edit, status: :unprocessable_entity
  end

  # Public home page (for all users)
  def index
       @sections = HomePageStore.read
  end

  # Member Login Page
  def login
       redirect_to member_center_path if user_signed_in?
  end

  def member_center
       # require_member! above already guarantees a signed-in member
       @user = current_user
    @shared_user.gallery_photos.load
  end

  def upload_gallery
       if params[:gallery_photos].present?
            @shared_user.gallery_photos.attach(params[:gallery_photos])
         flash[:success] = "#{params[:gallery_photos].count} photo(s) uploaded successfully."
       else
            flash[:alert] = "No photos selected for upload."
       end
    redirect_to member_center_path
  end

  def delete_gallery_photo
       photo = @shared_user.gallery_photos.find_by(id: params[:photo_id])
    if photo
         photo.purge
      flash[:success] = "Photo deleted successfully."
    else
         flash[:alert] = "Photo not found."
    end
    redirect_to member_center_path
  end

  private

       def set_shared_user
            @shared_user = User.find_by(email: "shared@domain.com")
         return if @shared_user

         @shared_user = User.new(
           email:      "shared@domain.com",
           first_name: "Shared",
           last_name:  "User",
           role:       :exec,   # enum -> valid value
           status:     :active, # enum -> valid value
           position:   nil
         )

         # Some setups ignore password (omniauth-only). Set it only if supported.
         @shared_user.password = SecureRandom.hex(16) if @shared_user.respond_to?(:password=)

         @shared_user.save!
       end
end
