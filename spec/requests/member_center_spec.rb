# spec/requests/member_center_spec.rb
require 'rails_helper'

RSpec.describe "Member Center", type: :request do
  include Devise::Test::IntegrationHelpers
  
  let(:member) { create(:user, role: "member") }
  let(:exec) { create(:user, role: "exec") }
  let!(:shared_user) { create(:user, email: "shared@domain.com") }

  describe "GET /member_center" do
    context "when user is not signed in" do
      it "redirects to login page" do
        get member_center_path
        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include("Please sign in to continue.")
      end
    end

    context "when user is signed in" do
      before { sign_in member }

      it "renders the member center successfully" do
        get member_center_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Welcome #{member.first_name}")
      end
    end
  end

  describe "POST /member_center/upload_gallery" do
    before { sign_in exec }

    let(:image_file) { fixture_file_upload(Rails.root.join("spec/fixtures/files/test_image.png"), "image/png") }

    context "with valid photo(s)" do
      it "uploads photo(s) successfully and sets success flash" do
        post upload_gallery_path, params: { gallery_photos: [image_file] }
        expect(response).to redirect_to(member_center_path)
        follow_redirect!
        expect(response.body).to include("photo(s) uploaded successfully")
      end
    end

    context "with no photos selected" do
      it "sets alert flash message" do
        post upload_gallery_path
        expect(flash[:alert]).to eq("No photos selected for upload.")
      end
    end
  end

  describe "DELETE /member_center/delete_gallery_photo/:photo_id" do
    before do
      sign_in exec
      shared_user.gallery_photos.attach(io: File.open(Rails.root.join("spec/fixtures/files/test_image.png")), filename: "test_image.png", content_type: "image/png")
    end

    it "deletes the photo successfully" do
      photo = shared_user.gallery_photos.first
      delete delete_gallery_photo_path(photo_id: photo.id)
      expect(response).to redirect_to(member_center_path)
      follow_redirect!
      expect(flash[:success]).to eq("Photo deleted successfully.")
    end

    it "handles missing photo gracefully" do
      delete delete_gallery_photo_path(photo_id: "nonexistent")
      expect(flash[:alert]).to eq("Photo not found.")
    end
  end
end
