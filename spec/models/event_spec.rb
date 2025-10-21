require 'rails_helper'

RSpec.describe Event, type: :model do
     let(:category) { create(:event_category) }

  # Sunny day
  describe "validations" do
       subject do
            build(:event,
              name: "Sample Event",
              description: "A test event",
              event_category: category,
              starts_at: 1.day.from_now,
              ends_at: 2.days.from_now,
              visibility: :public_event,
              published: :draft,
              location_type: "campus",
              campus_code: "ENGR",
              campus_number: 101
            )
       end

    it "is valid with valid attributes" do
         expect(subject).to be_valid
    end

    it "saves successfully" do
         expect { subject.save! }.not_to raise_error
    end
  end

  # Rainy day
  describe "invalid cases" do
       it "is invalid without a name" do
            event = build(:event, name: nil)
         expect(event).not_to be_valid
         expect(event.errors[:name]).to include("can't be blank")
       end

    it "is invalid without a description" do
         event = build(:event, description: nil)
      expect(event).not_to be_valid
    end

    it "is invalid if ends_at is before starts_at" do
         event = build(:event, starts_at: 2.days.from_now, ends_at: 1.day.from_now)
      expect(event).not_to be_valid
      expect(event.errors[:ends_at]).to include("must be after start time")
    end

    it "requires campus fields when location_type is campus" do
         event = build(:event, location_type: "campus", campus_code: nil, campus_number: nil)
      expect(event).not_to be_valid
      expect(event.errors[:campus_code]).to include("can't be blank")
      expect(event.errors[:campus_number]).to include("can't be blank")
    end

    it "requires off_campus fields when location_type is off_campus" do
         event = build(:event, location_type: "off_campus", location_name: nil, address: nil)
      expect(event).not_to be_valid
      expect(event.errors[:location_name]).to include("can't be blank")
      expect(event.errors[:address]).to include("can't be blank")
    end

    it "requires location_text when location_type is other_location" do
         event = build(:event, location_type: "other_location", location_text: nil)
      expect(event).not_to be_valid
      expect(event.errors[:location_text]).to include("can't be blank")
    end
  end

  describe "enums" do
       it "defines visibility values" do
            expect(Event.visibilities.keys).to include("public_event", "members_only", "execs_only")
       end

    it "defines published values" do
         expect(Event.publisheds.keys).to include("draft", "published", "unpublished")
    end
  end

    describe "scopes" do
         let!(:upcoming_event) { create(:event, name: "Upcoming Event", starts_at: 2.days.from_now, ends_at: 3.days.from_now, published: :published) }
    let!(:past_event)     { create(:event, name: "Past Event", starts_at: 3.days.ago, ends_at: 2.days.ago, published: :published) }
    let!(:draft_event)    { create(:event, name: "Draft Event", starts_at: 1.day.from_now, ends_at: 2.days.from_now, published: :draft) }

    it "returns upcoming events" do
         expect(Event.upcoming).to include(upcoming_event)
        expect(Event.upcoming).not_to include(past_event)
    end

    it "returns past events" do
         expect(Event.past).to include(past_event)
        expect(Event.past).not_to include(upcoming_event)
    end

    it "returns only published events" do
         expect(Event.published_only).to include(upcoming_event, past_event)
        expect(Event.published_only).not_to include(draft_event)
    end
    end

  describe "callbacks" do
       it "clears irrelevant fields when location_type changes" do
            event = build(:event, location_type: "campus", campus_code: "ENGR", campus_number: 101,
                                  location_name: "Offsite", address: "123 St", location_text: "Somewhere")
         event.valid?
         expect(event.location_name).to be_nil
         expect(event.address).to be_nil
         expect(event.location_text).to be_nil
       end

    let(:category) { create(:event_category) }

    it "sets location before save" do
         event = build(:event, event_category: category, location_type: "campus", campus_code: "ENGR", campus_number: 101)
    event.save!
    expect(event.location).to eq("ENGR - 101")
    end
  end

  describe "#full_location" do
       it "returns campus location string" do
            event = build(:event, location_type: "campus", campus_code: "ENGR", campus_number: 101)
         expect(event.full_location).to eq("ENGR - 101")
       end

    it "returns off_campus location string" do
         event = build(:event, location_type: "off_campus", location_name: "Hall", address: "123 St")
      expect(event.full_location).to eq("Hall - 123 St")
    end

    it "returns other_location string" do
         event = build(:event, location_type: "other_location", location_text: "Virtual")
      expect(event.full_location).to eq("Virtual")
    end
  end

  describe "helper methods" do
       it "returns true for on_campus? when location_type is campus" do
            event = build(:event, location_type: "campus")
         expect(event.on_campus?).to be true
         expect(event.off_campus?).to be false
         expect(event.other_location?).to be false
       end
  end
end
