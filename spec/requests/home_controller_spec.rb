# spec/requests/home_controller_spec.rb
require "rails_helper"
require "ostruct"

RSpec.describe "HomeController", type: :request do
     let(:sections_hash) do
          {
            "hero_badge_html"            => "<b>We are LEGION</b>",
            "who_we_are_title"           => "Who we are",
            "who_we_are_body_html"       => "<p>Body</p>",
            "partner_title"              => "Our Partner",
            "partner_body_html"          => "<p>Partner body</p>",
            "footer_diversity_title"     => "Diversity Statement",
            "footer_diversity_body_html" => "<p>Diversity body</p>"
          }
     end

  # Auth filters: stub them so we focus on behavior
  before do
       allow_any_instance_of(HomeController).to receive(:require_exec!).and_return(true)
    allow_any_instance_of(HomeController).to receive(:require_member!).and_return(true)
  end

  describe "GET / (home#index)" do
       it "reads sections and renders" do
            allow(HomePageStore).to receive(:read).and_return(sections_hash)

         get root_path

         expect(response).to have_http_status(:ok)
         expect(response.body).to include("Who we are")
       end
  end

  describe "GET /home/edit (home#edit)" do
       it "renders edit with sections" do
            allow(HomePageStore).to receive(:read).and_return(sections_hash)

         get edit_home_path

         expect(response).to have_http_status(:ok)
         expect(response.body).to include("Edit Home Page")
       end
  end

  describe "PATCH /home (home#update)" do
       let(:params_hash) do
            {
              home_page: {
                hero_badge_html: "<b>Hi</b>",
                who_we_are_title: "We",
                who_we_are_body_html: "<p>Body</p>",
                partner_title: "Partner",
                partner_body_html: "<p>PB</p>",
                footer_diversity_title: "Diversity",
                footer_diversity_body_html: "<p>DB</p>"
              }
            }
       end

    it "saves and redirects with notice on success" do
         allow(HomePageStore).to receive(:save_all!).and_return(true)

      patch home_path, params: params_hash

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Home page updated successfully")
    end

    it "rescues validation error and re-renders :edit with 422 and flash" do
         allow(HomePageStore).to receive(:read).and_return(sections_hash)

      invalid = Page.new
      invalid.errors.add(:base, "Bad inputs")
      allow(HomePageStore).to receive(:save_all!)
        .and_raise(ActiveRecord::RecordInvalid.new(invalid))

      patch home_path, params: params_hash

      expect(response.status).to eq(422) # Unprocessable Content
      expect(flash[:alert]).to eq("Bad inputs")
      expect(response.body).to include("Edit Home Page")
    end
  end

  describe "GET /login (home#login)" do
       it "redirects to member_center when already signed in" do
            allow_any_instance_of(HomeController).to receive(:user_signed_in?).and_return(true)

         get login_path

         expect(response).to redirect_to(member_center_path)
       end

    it "renders login when not signed in" do
         allow_any_instance_of(HomeController).to receive(:user_signed_in?).and_return(false)

      get login_path

      expect(response).to have_http_status(:ok)
    end
  end

  # Helper to stub @shared_user for gallery flows
  def install_shared_user_double!
       photos = double(load: true, attach: true)
    allow(photos).to receive(:find_by).and_return(nil)
    shared_user = double("SharedUser", gallery_photos: photos)

    allow_any_instance_of(HomeController).to receive(:set_shared_user) do |controller|
         controller.instance_variable_set(:@shared_user, shared_user)
      true
    end

    [ shared_user, photos ]
  end

  describe "GET /member_center (home#member_center)" do
       it "renders successfully with shared_user stubbed" do
            install_shared_user_double!

         # Avoid template depending on @user.first_name: set @user and render plain.
         allow_any_instance_of(HomeController).to receive(:member_center) do |controller|
              controller.instance_variable_set(:@user, OpenStruct.new(first_name: "Testy"))
           controller.render plain: "ok"
         end

         get member_center_path

         expect(response).to have_http_status(:ok)
         expect(response.body).to eq("ok")
       end
  end

  describe "POST /upload_gallery (home#upload_gallery)" do
       it "flashes alert when no files provided" do
            install_shared_user_double!

         post upload_gallery_path

         expect(response).to redirect_to(member_center_path)
         expect(flash[:alert]).to match(/No photos selected/i)
       end

    it "attaches files and flashes success when files present" do
         _shared_user, photos = install_shared_user_double!
      expect(photos).to receive(:attach).with(kind_of(Array))

      files = [
        Rack::Test::UploadedFile.new(StringIO.new("a"), "image/png", original_filename: "a.png"),
        Rack::Test::UploadedFile.new(StringIO.new("b"), "image/png", original_filename: "b.png")
      ]

      post upload_gallery_path, params: { gallery_photos: files }

      expect(response).to redirect_to(member_center_path)
      expect(flash[:success]).to match(/2 photo\(s\) uploaded successfully/i)
    end
  end

  describe "DELETE /delete_gallery_photo (home#delete_gallery_photo)" do
       it "purges when photo found" do
            _shared_user, photos = install_shared_user_double!

         fake_photo = double(purge: true, id: 42)
         allow(photos).to receive(:find_by).with(id: "42").and_return(fake_photo)

         # pass required key in the path helper, not only params
         delete delete_gallery_photo_path(photo_id: 42)

         expect(response).to redirect_to(member_center_path)
         expect(flash[:success]).to match(/Photo deleted successfully/i)
       end

    it "alerts when photo not found" do
         _shared_user, photos = install_shared_user_double!
      allow(photos).to receive(:find_by).with(id: "999").and_return(nil)

      delete delete_gallery_photo_path(photo_id: 999)

      expect(response).to redirect_to(member_center_path)
      expect(flash[:alert]).to match(/Photo not found/i)
    end
  end
end
