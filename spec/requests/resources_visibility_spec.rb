# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Resources visibility", type: :request do
     include Devise::Test::IntegrationHelpers

  let!(:member) { create(:user, :member) }
  let!(:exec)   { create(:user, :exec) }


  let!(:category) { ResourceCategory.create!(name: "Docs") }

  # helper to attach a real file
  let(:test_pdf) do
       Rack::Test::UploadedFile.new(
         Rails.root.join("spec/fixtures/files/test.pdf"),
         "application/pdf"
       )
  end

  # Published resources
  let!(:pub_pub)   { Resource.create!(name: "Public Doc",  visibility: :public_resource,  published: "published",  resource_category: category, file: test_pdf, resource_type: "file") }
  let!(:mem_pub)   { Resource.create!(name: "Members Doc", visibility: :members_only,     published: "published",  resource_category: category, file: test_pdf, resource_type: "file") }
  let!(:exe_pub)   { Resource.create!(name: "Exec Doc",    visibility: :execs_only,       published: "published",  resource_category: category, file: test_pdf, resource_type: "file") }
  let!(:pub_draft) { Resource.create!(name: "Draft Public", visibility: :public_resource,  published: "draft",      resource_category: category, file: test_pdf, resource_type: "file") }

  describe "GET /resources (public index)" do
       context "sunny day" do
            it "guest sees only public published resources" do
                 get resources_path
              expect(response).to have_http_status(:ok)
              expect(response.body).to include("Public Doc")
              expect(response.body).not_to include("Members Doc")
              expect(response.body).not_to include("Exec Doc")
              expect(response.body).not_to include("Draft Public")
            end

         it "member sees public + members resources" do
              sign_in member
           get resources_path
           expect(response).to have_http_status(:ok)
           expect(response.body).to include("Public Doc")
           expect(response.body).to include("Members Doc")
           expect(response.body).not_to include("Exec Doc")
         end

         it "exec sees all published resources" do
              sign_in exec
           get resources_path
           expect(response).to have_http_status(:ok)
           expect(response.body).to include("Public Doc")
           expect(response.body).to include("Members Doc")
           expect(response.body).to include("Exec Doc")
         end
       end
  end

  describe "GET /dashboard/resources (admin/dashboard access)" do
       context "rainy day: unauthorized access" do
            it "redirects guest and member users" do
                 get dashboard_resources_path
              expect(response).to have_http_status(302).or have_http_status(:found)

              sign_in member
              get dashboard_resources_path
              expect(response).to have_http_status(302).or have_http_status(:found)
            end
       end

    context "sunny day: exec access" do
         it "allows exec to see dashboard" do
              sign_in exec
           get dashboard_resources_path
           expect(response).to have_http_status(:ok)
           expect(response.body).to include("All Resources")
         end
    end
  end
end
