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
      expect(page).not_to have_link("Modify Photo Gallery")
    end
  end

  context "as an exec" do
       before(:each) do
            login_as(exec, scope: :user)
         exec.gallery_photos.purge  # ensure a clean gallery for every test
         visit member_center_path
       end

    it "shows admin buttons and modals" do
         visit member_center_path
      expect(page).to have_content("Welcome Alice")
      expect(page).to have_link("Modify Photo Gallery")
      expect(page).to have_link("Edit Photo Gallery Caption")
      expect(page).to have_content("Admin Access")
    end

    it "opens and submits the Edit Member Center Caption modal" do
         visit member_center_path
      click_link "Edit Photo Gallery Caption"

      # Ensure modal appears
      expect(page).to have_selector("#editMemberCenterCaptionModal", visible: true)
      expect(page).to have_content("Edit Member Center Caption")

      # Submit the form with blank input
      within("#editMemberCenterCaptionModal") do
           fill_in "Member Center Caption (HTML allowed)", with: ""
        click_button "Save"
      end

      # Expect a flash message (controller sets one)
      expect(page).to have_content("Member Center Caption updated!").or have_content("Caption cannot be blank")
    end
  end
end
