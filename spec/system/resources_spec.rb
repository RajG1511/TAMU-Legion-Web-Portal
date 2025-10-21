# spec/system/resources_spec.rb
require "rails_helper"

RSpec.describe "Resource management", type: :system do
     let!(:category) { ResourceCategory.create!(name: "General") }
  let(:pdf_path) { Rails.root.join("spec/fixtures/files/test.pdf") }

  include Warden::Test::Helpers
  before(:each) { Warden.test_mode! }
  after(:each)  { Warden.test_reset! }

  let(:user) { create(:user, :exec, password: "password123") }

  before do
       login_as(user, scope: :user)
  end

  before do
       driven_by(:rack_test) # stays on rack_test, no JS required
  end


  describe "creating a resource" do
       context "sunny day" do
            it "admin can create a new resource successfully with file" do
                 visit new_resource_path

              fill_in "Resource Name", with: "New Resource"
              select category.name, from: "Category"
              select "Public resource", from: "Visibility"

              # Bypass JS hidden field by setting style for test
              choose "File Upload"
              attach_file "Upload File", pdf_path, visible: :all

              click_button "Create Resource"

              expect(page).to have_content("Resource created successfully")
              expect(Resource.last.name).to eq("New Resource")
            end
       end

    context "rainy day" do
         it "shows validation errors when required fields are missing" do
              visit new_resource_path
           click_button "Create Resource"

           expect(page).to have_content("Please fill out all required fields")
         end
    end
  end

  describe "updating a resource" do
       it "admin can update an existing resource" do
            resource = Resource.create!(
              name: "Old Resource",
              resource_category: category,
              visibility: :public_resource,
              published: :draft,
              resource_type: "file",
              file: Rack::Test::UploadedFile.new(pdf_path, "application/pdf")
            )

         visit edit_resource_path(resource)

         fill_in "Resource Name", with: "Updated Resource"
         click_button "Update Resource"

         expect(page).to have_content("Resource updated successfully")
         expect(resource.reload.name).to eq("Updated Resource")
       end
  end

  describe "publishing and unpublishing a resource" do
       it "admin can toggle publish/unpublish without JS" do
            resource = Resource.create!(
              name: "Draft Doc",
              resource_category: category,
              visibility: :public_resource,
              published: :draft,
              resource_type: "file",
              file: Rack::Test::UploadedFile.new(pdf_path, "application/pdf")
            )

         # Directly send PATCH request to toggle_publish path
         patch toggle_publish_resource_path(resource)
         resource.reload
         expect(resource.published).to eq("published")

         patch toggle_publish_resource_path(resource)
         resource.reload
         expect(resource.published).to eq("unpublished")
       end
  end
end
