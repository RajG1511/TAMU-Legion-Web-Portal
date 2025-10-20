# spec/requests/recruitment_controller_spec.rb
require "rails_helper"

RSpec.describe "RecruitmentController", type: :request do
     before do
          # Skip the auth guard so we can exercise controller paths
          allow_any_instance_of(RecruitmentController).to receive(:require_exec!).and_return(true)
     end

  let(:sections_hash) do
       {
         "hero_title"        => "Recruitment",
         "hero_tagline_html" => "Tagline",
         "body_html"         => "<p>Body</p>",
         "apply_url"         => "https://example.com/apply",
         "groupme_url"       => "https://example.com/groupme",
         "contact_email"     => "contact@example.com"
       }
  end

  describe "GET /recruitment" do
       it "reads sections and renders" do
            allow(RecruitmentPageStore).to receive(:read).and_return(sections_hash)

         get recruitment_path

         expect(response).to have_http_status(:ok)
         expect(response.body).to include("Recruitment") # default hero_title
       end
  end

  describe "GET /recruitment/edit" do
       it "renders edit" do
            allow(RecruitmentPageStore).to receive(:read).and_return(sections_hash)

         get edit_recruitment_path

         expect(response).to have_http_status(:ok)
         expect(response.body).to include("Edit Recruitment Page")
       end
  end

  describe "PATCH /recruitment" do
       let(:params_hash) do
            {
              recruitment_page: {
                hero_title: "New",
                hero_tagline_html: "<p>Tag</p>",
                body_html: "<div>Body</div>",
                apply_url: "https://example.com/apply",
                groupme_url: "https://example.com/groupme",
                contact_email: "contact@example.com"
              }
            }
       end

    it "saves and redirects with notice on success" do
         allow(RecruitmentPageStore).to receive(:save_all!).and_return(true)

      patch update_recruitment_path, params: params_hash

      expect(response).to redirect_to(recruitment_path)
      follow_redirect!
      expect(response.body).to include("Recruitment page updated.")
    end

    it "rescues validation error and re-renders :edit with 422" do
         # make edit re-render path have sections
         allow(RecruitmentPageStore).to receive(:read).and_return(sections_hash)

      invalid = Page.new
      invalid.errors.add(:base, "Bad inputs")
      allow(RecruitmentPageStore).to receive(:save_all!)
        .and_raise(ActiveRecord::RecordInvalid.new(invalid))

      patch update_recruitment_path, params: params_hash

      expect(response.status).to eq(422)         # Unprocessable Content
      expect(flash[:alert]).to eq("Bad inputs")  # assert flash instead of HTML
      expect(response.body).to include("Edit Recruitment Page")
    end
  end
end
