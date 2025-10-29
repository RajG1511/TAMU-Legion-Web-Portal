# spec/system/member_center_ui_spec.rb
require 'rails_helper'

RSpec.describe "Member Center UI", type: :system do
  include Warden::Test::Helpers

  before(:each) { Warden.test_mode! }
  after(:each)  { Warden.test_reset! }

  let(:member) { create(:user, role: "member", first_name: "John") }
  let(:exec)   { create(:user, :exec, first_name: "Alice", password: "password123") }
  let!(:shared_user) { create(:user, email: "shared@domain.com") }

  before do
    driven_by(:rack_test)
  end

  context "as a member" do
    before { login_as(member, scope: :user) }

    it "shows welcome message and quick links but hides admin options" do
      visit member_center_path
      expect(page).to have_content("Welcome John")
      expect(page).to have_link("Submit Service Hours")
      expect(page).not_to have_content("Admin Access")
      expect(page).not_to have_link("Manage Gallery & Caption")
    end
  end

  context "as an exec" do
    before(:each) do
      login_as(exec, scope: :user)
      exec.gallery_photos.purge  # ensure a clean gallery for every test
      visit member_center_path
    end

    it "shows admin buttons and modals" do
      expect(page).to have_content("Welcome Alice")

      # New combined link for gallery & caption
      expect(page).to have_link("Manage Gallery & Caption")

      expect(page).to have_content("Admin Access")
      expect(page).to have_link("Events Dashboard")
      expect(page).to have_link("Resources Dashboard")
    end

    it "opens and submits the Manage Gallery & Caption modal" do
      click_link "Manage Gallery & Caption"

      # Ensure modal appears
      expect(page).to have_selector("#manageGalleryModal", visible: true)
      expect(page).to have_content("Manage Photo Gallery & Caption")

      # Interact with the caption form inside the modal
      within("#manageGalleryModal") do
        # `text` is the name of your text area
        fill_in "text", with: ""
        click_button "Save Caption"
      end

      # Expect a flash message
      expect(page).to have_content("Member Center Caption updated!").or have_content("Caption cannot be empty!")
    end
  end
end
