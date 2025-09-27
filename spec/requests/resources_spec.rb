require "rails_helper"

RSpec.describe "Resources", type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  let(:category) { create(:resource_category) }
  let!(:user) { create(:user) }

  let(:valid_file) do
    fixture_file_upload(Rails.root.join("spec/fixtures/files/test.pdf"), "application/pdf")
  end

  describe "GET /resources" do
    it "renders the index with published resources" do
      resource = create(:resource, published: true, resource_category: category)
      get resources_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(resource.name)
    end

    it "does not show unpublished resources" do
      resource = create(:resource, published: false, resource_category: category)
      get resources_path
      expect(response.body).not_to include(resource.name)
    end
  end

  describe "POST /resources" do
    let(:valid_params) do
      {
        resource: {
          name: "New Resource",
          content: "Some description",
          visibility: "public_resource",
          resource_category_id: category.id,
          file: valid_file
        }
      }
    end

    let(:invalid_params) do
      {
        resource: {
          name: "", # invalid
          visibility: "public_resource",
          resource_category_id: nil # invalid
        }
      }
    end

    it "creates a resource with valid params" do
      expect {
        post resources_path, params: valid_params
        puts response.body
      }.to change(Resource, :count).by(1)
      expect(response).to redirect_to(dashboard_resources_path)
      expect(Resource.last.name).to eq("New Resource")
    end

    it "does not create a resource with invalid params" do
      expect {
        post resources_path, params: invalid_params
      }.not_to change(Resource, :count)
      expect(response.body).to include("Please fill out all required fields.")
    end
  end

  describe "PATCH /resources/:id" do
    let!(:resource) { create(:resource, resource_category: category) }

    it "updates with valid params" do
      patch resource_path(resource), params: {
        resource: { name: "Updated Name" }
      }
      puts response.body
      expect(response).to redirect_to(dashboard_resources_path)
      expect(resource.reload.name).to eq("Updated Name")
    end

    it "does not update with invalid params" do
      patch resource_path(resource), params: {
        resource: { name: "" }
      }
      expect(response.body).to include("Please fill out all required fields.")
    end
  end

  describe "DELETE /resources/:id" do  
    let!(:resource) { create(:resource, resource_category: category) }
    it "deletes the resource" do
      expect {
        delete resource_path(resource)
      }.to change(Resource, :count).by(-1)
      expect(response).to redirect_to(dashboard_resources_path)
    end
  end

  describe "PATCH /resources/:id/toggle_publish" do
    let!(:resource) { create(:resource, published: false, resource_category: category) }

    it "toggles published state" do
      patch toggle_publish_resource_path(resource)
      expect(resource.reload.published).to be true
    end
  end
end