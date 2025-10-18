<<<<<<< HEAD
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
=======
# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Resources", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:category) { create(:resource_category, name: "Policies") }

  let!(:exec) { create(:user, :exec, email: "exec@example.org", password: "password123") }
  let!(:member) { create(:user, :member, email: "member@example.org", password: "password123") }

  let(:pdf_file) { fixture_file_upload(Rails.root.join("spec/fixtures/files/test.pdf"), "application/pdf") }
  let(:upload)    { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test.pdf"), "application/pdf") }


  describe "GET /resources (member view)" do
    let!(:public_resource) { create(:resource, :with_file, name: "Public File", visibility: :public_resource, published: :published, resource_category: category) }
    let!(:member_resource) { create(:resource, :with_file, name: "Members Only File", visibility: :members_only, published: :published, resource_category: category) }
    let!(:exec_resource) { create(:resource, :with_file, name: "Exec Only File", visibility: :execs_only, published: :published, resource_category: category) }
    let!(:unpublished) { create(:resource, :with_file, name: "Unpublished File", visibility: :public_resource, published: :draft, resource_category: category) }

    it "shows only published resources for non-signed in users" do
      get resources_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(public_resource.name)
      expect(response.body).not_to include(member_resource.name)
      expect(response.body).not_to include(exec_resource.name)
      expect(response.body).not_to include(unpublished.name)
    end

    it "shows member-visible resources for signed-in members" do
      sign_in member
      get resources_path
      expect(response.body).to include(public_resource.name)
      expect(response.body).to include(member_resource.name)
      expect(response.body).not_to include(exec_resource.name)
      expect(response.body).not_to include(unpublished.name)
    end

    it "shows all resources for signed-in execs" do
      sign_in exec
      get resources_path
      expect(response.body).to include(public_resource.name)
      expect(response.body).to include(member_resource.name)
      expect(response.body).to include(exec_resource.name)
      expect(response.body).not_to include(unpublished.name)
    end
  end

    describe "POST /resources (admin actions)" do
    before { sign_in exec }

    let(:valid_params) do
      {
        resource: {
          name: "Employee Handbook",
          visibility: "public_resource",
          resource_category_id: category.id,
          file: upload,
          content: "The official handbook",
          resource_type: "file"
        }
      }
    end

    let(:invalid_params) do
      {
        resource: {
          name: "",
          visibility: "",
          resource_category_id: nil,
          file: nil,
          content: "",
          resource_type: "file"
        }
      }
    end

    context "with valid parameters (sunny day)" do
      it "creates a new resource and redirects to dashboard" do
        expect {
          post resources_path, params: valid_params
        }.to change(Resource, :count).by(1)

        resource = Resource.last
        expect(resource.name).to eq("Employee Handbook")
        expect(resource.file).to be_attached

        expect(response).to redirect_to(dashboard_resources_path)
        follow_redirect!
        expect(response.body).to include("Resource created successfully.")
        expect(response.body).to include("Employee Handbook")
      end
    end

    context "with invalid parameters (rainy day)" do
      it "does not create a resource and shows errors" do
        expect {
          post resources_path, params: invalid_params
        }.not_to change(Resource, :count)

        expect(response).to have_http_status(:unprocessable_entity).or have_http_status(:ok)
        expect(response.body).to include("Please fill out all required fields.")
      end
    end
  end


  describe "PATCH /resources/:id (update)" do
    let!(:resource) { create(:resource, :with_file, name: "Old Name", resource_category: category) }
    before { sign_in exec }

    context "with valid params" do
      it "updates the resource" do
        patch resource_path(resource), params: { resource: { name: "Updated Name" } }
        expect(response).to redirect_to(dashboard_resources_path)
        expect(resource.reload.name).to eq("Updated Name")
      end
    end

    context "with invalid params" do
      it "does not update the resource" do
        patch resource_path(resource), params: { resource: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity).or have_http_status(:ok)
        expect(response.body).to include("Please fill out all required fields.")
        expect(resource.reload.name).to eq("Old Name")
      end
    end
  end

  describe "DELETE /resources/:id" do
    let!(:resource) { create(:resource, :with_file, name: "To Delete", resource_category: category) }
    before { sign_in exec }

    it "deletes the resource" do
      expect {
        delete resource_path(resource)
      }.to change(Resource, :count).by(-1)
      expect(response).to redirect_to(dashboard_resources_path)
    end
  end

  describe "PATCH /resources/:id/toggle_publish" do
    let!(:resource) { create(:resource, :with_file, name: "Toggle Me", published: :draft, resource_category: category) }
    before { sign_in exec }

    it "toggles the published state" do
      patch toggle_publish_resource_path(resource)
      expect(response).to redirect_to(dashboard_resources_path)
      expect(resource.reload.published).to eq("published")

      patch toggle_publish_resource_path(resource)
      expect(resource.reload.published).to eq("unpublished")
    end
  end
end
>>>>>>> origin/test
