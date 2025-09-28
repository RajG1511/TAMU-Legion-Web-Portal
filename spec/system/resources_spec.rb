require "rails_helper"

RSpec.describe "Resource management", type: :system do
  let!(:category) { create(:resource_category, name: "Policies") }
  let!(:user) { create(:user) } # adjust if you need login

  before do
    driven_by(:rack_test) # or :selenium_chrome_headless if you want JS
  end

  it "allows admin to create a new resource (sunny day)" do
    visit new_resource_path

    fill_in "Name", with: "Employee Handbook"
    select "Public resource", from: "Visibility"
    select "Policies", from: "Category"
    attach_file "Upload File", Rails.root.join("spec/fixtures/files/test.pdf")
    fill_in "Description (optional)", with: "The official handbook"

    click_button "Create Resource"

    expect(page).to have_content("Resource created successfully.")
    expect(page).to have_content("Employee Handbook")
    expect(page).to have_content("Policies")
    expect(page).to have_content("test.pdf")
  end

  it "shows validation errors when required fields are missing (rainy day)" do
    visit new_resource_path
    click_button "Create Resource"

    expect(page).to have_content("Please fill out all required fields.")
    expect(page).to have_content("Name can't be blank")
    expect(page).to have_content("File can't be blank")
  end

  it "allows admin to update an existing resource" do
    resource = create(:resource, resource_category: category)

    visit edit_resource_path(resource)

    fill_in "Name", with: "Updated Resource Name"
    click_button "Update Resource"

    expect(page).to have_content("Resource updated successfully.")
    expect(page).to have_content("Updated Resource Name")
  end

  it "allows admin to toggle publish/unpublish" do
    resource = create(:resource, resource_category: category, published: false)

    visit dashboard_resources_path
    expect(page).to have_button("Publish")

    click_button "Publish"
    expect(page).to have_content("Resource published successfully.")

    expect(resource.reload.published).to be true
  end
end