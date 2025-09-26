require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:category) { create(:event_category) }
  let(:user)     { create(:user) } # needed because log_event_version uses User.last
  let(:valid_attributes) do
    attributes_for(:event, event_category_id: category.id)
  end
  let(:invalid_attributes) do
    { name: "", starts_at: nil, ends_at: nil, event_category_id: nil }
  end
  let!(:event) { create(:event, event_category: category) }

  before do
    user # ensure at least one user exists
  end

  describe "GET #index" do
    it "returns published events" do
      event.update!(published: :published)
      get :index
      expect(assigns(:events)).to include(event)
      expect(response).to be_successful
    end

    it "filters by category" do
      get :index, params: { category_id: category.id }
      expect(assigns(:events).map(&:event_category_id)).to all(eq(category.id))
    end
  end

  describe "GET #dashboard" do
    it "returns all events and versions" do
      get :dashboard
      expect(assigns(:events)).to include(event)
      expect(assigns(:event_versions)).to be_present
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates an event and logs a version" do
        expect {
          post :create, params: { event: valid_attributes }
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
      it "does not create event and re-renders new" do
        expect {
          post :create, params: { event: invalid_attributes }
        }.not_to change(Event, :count)
        expect(response).to render_template(:new)
        expect(flash[:alert]).to eq("Please fill out all required fields.")
      end
    end
  end

  describe "PATCH #update" do
    it "updates the event and logs a version" do
      patch :update, params: { id: event.id, event: { name: "Updated Name" } }
      event.reload
      expect(event.name).to eq("Updated Name")

      version = EventVersion.last
      expect(version.change_type).to eq("updated")
      expect(version.event).to eq(event)
    end

    it "fails with invalid params" do
      patch :update, params: { id: event.id, event: invalid_attributes }
      expect(response).to render_template(:edit)
      expect(flash[:alert]).to eq("Please fill out all required fields.")
    end
  end

  describe "DELETE #destroy" do
    it "destroys the event and logs a version" do
      expect {
        delete :destroy, params: { id: event.id }
      }.to change(Event, :count).by(-1)
       .and change(EventVersion, :count).by(1)

      expect(response).to redirect_to(dashboard_events_path)
      version = EventVersion.last
      expect(version.change_type).to eq("deleted")
      expect(version.event_id).to eq(event.id)
    end
  end

  describe "PATCH #toggle_publish" do
    it "publishes an unpublished event and logs a version" do
      event.update!(published: :unpublished)

      expect {
        patch :toggle_publish, params: { id: event.id }
      }.to change(EventVersion, :count).by(1)

      event.reload
      expect(event.published).to eq("published")
      expect(EventVersion.last.change_type).to eq("published")
    end

    it "unpublishes a published event and logs a version" do
      event.update!(published: :published)

      expect {
        patch :toggle_publish, params: { id: event.id }
      }.to change(EventVersion, :count).by(1)

      event.reload
      expect(event.published).to eq("unpublished")
      expect(EventVersion.last.change_type).to eq("unpublished")
    end
  end
end