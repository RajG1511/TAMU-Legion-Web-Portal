require 'rails_helper'

RSpec.describe "AboutController", type: :request do
  let(:exec)   { create(:user, role: :exec) }

  before do
    # Stub AboutPageStore.read so views don’t blow up
    allow(AboutPageStore).to receive(:read).and_return({ "mission" => "Our mission" })
  end

  describe "GET /about" do
    it "renders the index page" do
      get about_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("About")
    end
  end

  describe "GET /about/edit" do
    context "as exec" do
      before { sign_in exec }

      it "renders the edit page" do
        get edit_about_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /about" do
    before { sign_in exec }

    context "with valid params" do
      it "saves and redirects" do
        allow(AboutPageStore).to receive(:save_all!).and_return(true)

        patch about_path, params: { about_page: { "mission" => "New mission" } }

        expect(response).to redirect_to(about_path)
        follow_redirect!
        expect(response.body).to include("About page updated.")
      end
    end
  end
end