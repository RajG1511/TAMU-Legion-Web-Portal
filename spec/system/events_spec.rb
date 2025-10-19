require 'rails_helper'

RSpec.describe "Events management", type: :system do
  let!(:category) { create(:event_category, name: "Tech") }
  
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

  context "sunny day" do
    it "allows a user to create a campus event and see it on the dashboard" do
      visit dashboard_events_path
      click_link "Create New Event"

      fill_in "Name", with: "Hackathon"
      select "Tech", from: "Event Category"
      fill_in "Description", with: "A 24-hour coding event"

      choose "On Campus"
      fill_in "Campus code", with: "ENGR", visible: :all
      fill_in "Campus number", with: 101, visible: :all

      fill_in "starts_at", with: 1.day.from_now.strftime("%Y-%m-%dT%H:%M"), visible: :all
      fill_in "ends_at",   with: 2.days.from_now.strftime("%Y-%m-%dT%H:%M"), visible: :all

      select "Public Event", from: "Visibility"

      click_button "Create Event"

      expect(page).to have_content("Event created successfully.")
      expect(page).to have_content("Hackathon")
      expect(page).to have_content("ENGR - 101")
    end

    it "lets a user navigate back to the dashboard from the form" do
      visit new_event_path
      click_link "← Back to Dashboard"
      expect(page).to have_current_path(dashboard_events_path)
    end

    it "allows editing an event from the dashboard" do
      event = create(:event, name: "Old Name", event_category: category, published: :published)

      visit dashboard_events_path
      click_link "Edit", href: edit_event_path(event)

      fill_in "Name", with: "Updated Event Name"
      click_button "Update Event"

      expect(page).to have_content("Event updated successfully.")
      expect(page).to have_content("Updated Event Name")
    end

    it "allows deleting an event from the dashboard" do
      event = create(:event, name: "Delete Me", event_category: category, published: :published)

      visit dashboard_events_path
      click_button "Delete", match: :first  # no accept_confirm with rack_test

      expect(page).to have_content("Event deleted successfully.")
      # Only check the event list, not the audit log
      within(".event-scroll-container ul") do
        expect(page).not_to have_content("Delete Me")
      end
    end

    it "allows publishing and unpublishing an event" do
      event = create(:event, name: "Toggle Event", event_category: category, published: :unpublished)

      visit dashboard_events_path
      click_button "Publish", match: :first
      expect(page).to have_content("Event published successfully.")
      expect(page).to have_button("Unpublish")

      click_button "Unpublish", match: :first
      expect(page).to have_content("Event unpublished successfully.")
      expect(page).to have_button("Publish")
    end

    it "shows published events on the member-facing index" do
      event = create(:event, name: "Public Event", event_category: category, published: :published)

      visit events_path
      expect(page).to have_content("Public Event")
      expect(page).to have_content(category.name)
    end
  end

  context "rainy day" do
    it "shows validation errors when required fields are missing" do
      visit new_event_path
      click_button "Create Event"

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Description can't be blank")
      expect(page).to have_content("Event category can't be blank")
      expect(page).to have_content("Starts at can't be blank")
      expect(page).to have_content("Ends at can't be blank")
      expect(page).to have_content("Location type") # covers both messages
      # Match the actual message your form shows
      expect(page).to have_content("Please fill out all required fields.")
    end

    it "shows error if end time is before start time" do
      visit new_event_path
      fill_in "Name", with: "Invalid Event"
      select "Tech", from: "Event Category"
      fill_in "Description", with: "Bad timing"
      choose "On Campus"
      fill_in "Campus code", with: "ENGR", visible: :all
      fill_in "Campus number", with: 101, visible: :all
      fill_in "starts_at", with: 2.days.from_now.strftime("%Y-%m-%dT%H:%M"), visible: :all
      fill_in "ends_at",   with: 1.day.from_now.strftime("%Y-%m-%dT%H:%M"), visible: :all
      select "Public Event", from: "Visibility"

      click_button "Create Event"

      expect(page).to have_content("Ends at must be after start time")
    end

    it "requires campus fields when location_type is campus" do
      visit new_event_path
      fill_in "Name", with: "Campus Event"
      select "Tech", from: "Event Category"
      fill_in "Description", with: "Missing campus fields"
      choose "On Campus"
      fill_in "starts_at", with: 1.day.from_now.strftime("%Y-%m-%dT%H:%M"), visible: :all
      fill_in "ends_at",   with: 2.days.from_now.strftime("%Y-%m-%dT%H:%M"), visible: :all
      select "Public Event", from: "Visibility"

      click_button "Create Event"

      expect(page).to have_content("Campus code can't be blank")
      expect(page).to have_content("Campus number can't be blank")
    end

    it "does not show unpublished events on the member-facing index" do
      create(:event, name: "Hidden Draft", event_category: category, published: :draft)

      visit events_path
      expect(page).not_to have_content("Hidden Draft")
    end
  end
end