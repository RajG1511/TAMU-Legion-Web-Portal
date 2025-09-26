require 'rails_helper'

RSpec.describe "Events", type: :request do
  let(:category) { create(:event_category) }
  let(:user)     { create(:user) } # needed because log_event_version uses User.last

  let(:valid_attributes) do
    attributes_for(:event,
      event_category_id: category.id,
      published: :published
    )
  end

  let(:invalid_attributes) do
    { name: "", starts_at: nil, ends_at: nil, event_category_id: nil }
  end

  let!(:event) do
    create(:event,
      name: "Visible Event",
      event_category: category,
      published: :published
    )
  end

  before { user }

  describe "GET /events" do
    it "returns published events regardless of date" do
      event.update!(starts_at: 3.days.ago, ends_at: 2.days.ago, published: :published)
      get events_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(event.name)
    end

    it "filters by category" do
      get events_path, params: { category_id: category.id }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(event.name)
    end

    it "does not show unpublished events" do
      draft_event = create(:event, name: "Hidden Draft", published: :draft)
      get events_path
      expect(response.body).to include(event.name)
      expect(response.body).not_to include(draft_event.name)
    end

    it "shows 'No upcoming events' if no published events exist" do
      Event.delete_all
      get events_path
      expect(response.body).to include("No upcoming events")
    end
  end

  describe "GET /dashboard/events" do
    it "returns all events regardless of published status" do
      draft_event = create(:event, name: "Draft Event", published: :draft)
      get dashboard_events_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(event.name)
      expect(response.body).to include(draft_event.name)
    end
  end

  describe "POST /events" do
    context "with valid params" do
      it "creates an event and logs a version" do
        expect {
          post events_path, params: { event: valid_attributes }
        }.to change(Event, :count).by(1)
         .and change(EventVersion, :count).by(1)

        expect(response).to redirect_to(dashboard_events_path)
        version = EventVersion.last
        expect(version.change_type).to eq("created")
        expect(version.event).to eq(Event.last)
        expect(version.user).to eq(User.last)
      end
    end

    context "with invalid params" do
      it "does not create event and shows errors" do
        expect {
          post events_path, params: { event: invalid_attributes }
        }.not_to change(Event, :count)

        expect(response).to have_http_status(:ok).or have_http_status(:unprocessable_content)
        expect(flash[:alert]).to eq("Please fill out all required fields.")
        expect(response.body).to include("Please fill out all required fields.")
      end
    end
  end

  describe "PATCH /events/:id" do
    it "updates the event and logs a version" do
      patch event_path(event), params: { event: { name: "Updated Name" } }
      event.reload
      expect(event.name).to eq("Updated Name")

      version = EventVersion.last
      expect(version.change_type).to eq("updated")
      expect(version.event).to eq(event)
    end

    it "fails with invalid params" do
      patch event_path(event), params: { event: invalid_attributes }
      expect(response).to have_http_status(:ok).or have_http_status(:unprocessable_content)
      expect(flash[:alert]).to eq("Please fill out all required fields.")
      expect(response.body).to include("Please fill out all required fields.")
    end
  end

  describe "DELETE /events/:id" do
    it "destroys the event and logs a version" do
      expect {
        delete event_path(event)
      }.to change(Event, :count).by(-1)
       .and change(EventVersion, :count).by(1)

      expect(response).to redirect_to(dashboard_events_path)
      version = EventVersion.last
      expect(version.change_type).to eq("deleted")
      expect(version.event_id).to eq(event.id)
    end
  end

  describe "PATCH /events/:id/toggle_publish" do
    it "publishes an unpublished event and logs a version" do
      event.update!(published: :unpublished)

      expect {
        patch toggle_publish_event_path(event)
      }.to change(EventVersion, :count).by(1)

      event.reload
      expect(event.published).to eq("published")
      expect(EventVersion.last.change_type).to eq("published")
    end

    it "unpublishes a published event and logs a version" do
      event.update!(published: :published)

      expect {
        patch toggle_publish_event_path(event)
      }.to change(EventVersion, :count).by(1)

      event.reload
      expect(event.published).to eq("unpublished")
      expect(EventVersion.last.change_type).to eq("unpublished")
    end
  end
end