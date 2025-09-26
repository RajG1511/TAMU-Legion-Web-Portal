require 'rails_helper'

RSpec.describe "Events management", type: :system do
  let!(:category) { create(:event_category, name: "Tech") }

  before do
    driven_by(:rack_test) # or :selenium_chrome_headless for JS
  end

  context "sunny day" do
    it "allows a user to create a campus event and see it on the dashboard" do
      visit dashboard_events_path
      click_link "New Event"

      fill_in "Name", with: "Hackathon"
      select "Tech", from: "Event Category"
      fill_in "Description", with: "A 24-hour coding event"

      choose "On Campus"
      fill_in "Campus code", with: "ENGR"
      fill_in "Campus number", with: 101

      fill_in "Start Time", with: 1.day.from_now.strftime("%Y-%m-%dT%H:%M")
      fill_in "End Time", with: 2.days.from_now.strftime("%Y-%m-%dT%H:%M")

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
      expect(page).to have_content("Location type must be selected")
      expect(page).to have_content("Visibility can't be blank")
    end

    it "shows error if end time is before start time" do
      visit new_event_path
      fill_in "Name", with: "Invalid Event"
      select "Tech", from: "Event Category"
      fill_in "Description", with: "Bad timing"
      choose "On Campus"
      fill_in "Campus code", with: "ENGR"
      fill_in "Campus number", with: 101
      fill_in "Start Time", with: 2.days.from_now.strftime("%Y-%m-%dT%H:%M")
      fill_in "End Time", with: 1.day.from_now.strftime("%Y-%m-%dT%H:%M")
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
      fill_in "Start Time", with: 1.day.from_now.strftime("%Y-%m-%dT%H:%M")
      fill_in "End Time", with: 2.days.from_now.strftime("%Y-%m-%dT%H:%M")
      select "Public Event", from: "Visibility"

      click_button "Create Event"

      expect(page).to have_content("Campus code can't be blank")
      expect(page).to have_content("Campus number can't be blank")
    end
  end
end