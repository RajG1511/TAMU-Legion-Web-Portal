# spec/system/committees_spec.rb
require 'rails_helper'

RSpec.describe "Committees management", type: :system do
  include Warden::Test::Helpers

  let(:new_user) { create(:user, first_name: 'Test', last_name: 'User') }
  let(:exec_user) { create(:user, :exec) }

  before(:each) do
    Warden.test_mode!
    login_as(exec_user, scope: :user)
    driven_by(:rack_test) # no JS needed
  end

  after(:each) do
    Warden.test_reset!
  end

context "as an executive" do
  it "can add and remove members from a committee" do
    committee = create(:committee, name: "Test Committee")
    visit edit_committee_path(committee)

    # Add member
    within("#add-member-form") do
      select new_user.full_name, from: "Add Member"
      click_button "Add Member"
    end
    expect(page).to have_content("#{new_user.full_name} added to committee #{committee.name}")

    # Remove member
    within("#remove-member-form") do
      select new_user.full_name, from: "Remove Member"
      click_button "Remove Member"
    end
    expect(page).to have_content("#{new_user.full_name} removed from committee #{committee.name}")

    # Ensure removed user is not in the remove-member dropdown
    within("#remove-member-form") do
      expect(page).not_to have_select(new_user.full_name)
    end
  end

    it "lists committees and allows creating, editing, and deleting" do
      # Create Committee
      visit new_committee_path
      fill_in "Committee Name", with: "New Committee"
      fill_in "Short Description", with: "Short desc"
      click_button "Create Committee"

      committee = Committee.find_by(name: "New Committee")
      expect(page).to have_content("Committee New Committee created.")

      # Edit Committee
      visit edit_committee_path(committee)
      fill_in "Short Description", with: "Updated description"
      click_button "Update Committee"
      expect(page).to have_content("Committee New Committee updated.")
      expect(page).to have_content("Updated description")

      # Delete Committee
      visit delete_committee_path(committee)
      click_button "Delete"

      # Check that the committee is no longer in the list (ignore flash)
      visit dashboard_committees_path
      within("#committees-list") do
        expect(page).not_to have_content("New Committee")
      end
    end
  end

  it "shows a committee page to any user" do
    committee = create(:committee, name: "Committee Name", description: "Committee Description")
    visit committee_path(committee)

    expect(page).to have_content("Committee Name")
    expect(page).to have_content("Committee Description")
  end
end
