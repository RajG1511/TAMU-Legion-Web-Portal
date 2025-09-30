# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Resources", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:category) { ResourceCategory.create!(name: "Policies") }
  let(:pdf_path)  { Rails.root.join("spec/fixtures/files/test.pdf") }
  let(:upload)    { Rack::Test::UploadedFile.new(pdf_path, "application/pdf") }

  # Exec user for admin/dashboard actions
  let!(:exec) do
    User.create!(
      email: "exec@example.org",
      first_name: "Exec",
      last_name: "User",
      role: :exec,
      status: :active
    )
  end

  describe "GET /resources" do
    it "renders the index with published resources" do
      Resource.create!(name: "Visible", visibility: :public_resource, published: true, resource_category: category, file: upload)
      Resource.create!(name: "Hidden",  visibility: :public_resource, published: false, resource_category: category, file: upload)

      get resources_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Visible")
      expect(response.body).not_to include("Hidden")
    end

    it "does not show unpublished resources" do
      Resource.create!(name: "Unpublished", visibility: :public_resource, published: false, resource_category: category, file: upload)

      get resources_path
      expect(response.body).not_to include("Unpublished")
    end
  end

  describe "POST /resources" do
    let(:valid_params) do
      {
        resource: {
          name: "Employee Handbook",
          visibility: "public_resource",
          resource_category_id: category.id,
          file: upload,
          content: "The official handbook"
        }
      }
    end

    let(:invalid_params) do
      {
        resource: {
          name: "",
          visibility: "",
          resource_category_id: "",
          file: nil,
          content: ""
        }
      }
    end

    before { sign_in exec }

    it "creates a resource with valid params" do
      expect {
        post resources_path, params: valid_params
      }.to change(Resource, :count).by(1)

      expect(response).to redirect_to(dashboard_resources_path)
      follow_redirect!
      expect(response.body).to include("Resource created successfully.")
      expect(response.body).to include("Employee Handbook")
    end

    it "does not create a resource with invalid params" do
      expect {
        post resources_path, params: invalid_params
      }.not_to change(Resource, :count)

      expect(response).to have_http_status(:unprocessable_entity).or have_http_status(:ok)
      expect(response.body).to include("Please fill out all required fields.")
    end
  end

  describe "PATCH /resources/:id" do
    before { sign_in exec }

    it "updates with valid params" do
      resource = Resource.create!(name: "Old", visibility: :public_resource, published: true, resource_category: category, file: upload)

      patch resource_path(resource), params: { resource: { name: "Updated" } }
      expect(response).to redirect_to(dashboard_resources_path)
      expect(resource.reload.name).to eq("Updated")
    end

    it "does not update with invalid params" do
      resource = Resource.create!(name: "Keep", visibility: :public_resource, published: true, resource_category: category, file: upload)

      patch resource_path(resource), params: { resource: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity).or have_http_status(:ok)
      expect(response.body).to include("Please fill out all required fields.")
      expect(resource.reload.name).to eq("Keep")
    end
  end

  describe "DELETE /resources/:id" do
    before { sign_in exec }

    it "deletes the resource" do
      resource = Resource.create!(name: "To Delete", visibility: :public_resource, published: true, resource_category: category, file: upload)

      expect {
        delete resource_path(resource)
      }.to change(Resource, :count).by(-1)
      expect(response).to redirect_to(dashboard_resources_path)
    end
  end

  describe "PATCH /resources/:id/toggle_publish" do
    before { sign_in exec }

    it "toggles published state" do
      resource = Resource.create!(name: "Toggle Me", visibility: :public_resource, published: false, resource_category: category, file: upload)

      patch toggle_publish_resource_path(resource)
      expect(response).to redirect_to(dashboard_resources_path)
      expect(resource.reload.published).to be true

      patch toggle_publish_resource_path(resource)
      expect(resource.reload.published).to be false
    end
  end
end
