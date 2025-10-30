require 'rails_helper'

RSpec.describe ServicesController, type: :request do
  let(:member) { create(:user, role: :member) }
  let(:exec)   { create(:user, role: :exec) }
  let(:service) { create(:service, user: member) }

  describe "GET /services" do
    context "as a member" do
      before { sign_in member }

      it "shows only their own services" do
        own_service = create(:service, user: member)
        other_service = create(:service) # belongs to someone else

        get services_path
        expect(response).to have_http_status(:ok)
        expect(assigns(:services)).to include(own_service)
        expect(assigns(:services)).not_to include(other_service)
      end
    end

    context "as an exec" do
      before { sign_in exec }

      it "shows all services" do
        service1 = create(:service)
        service2 = create(:service)

        get services_path
        expect(assigns(:services)).to match_array([service1, service2])
      end
    end
  end

  describe "POST /services" do
    before { sign_in member }

    it "creates a new service request" do
      expect {
        post services_path, params: { service: attributes_for(:service) }
      }.to change(Service, :count).by(1)

      expect(response).to redirect_to(services_path)
      follow_redirect!
      expect(response.body).to include("Service request submitted.")
    end
  end

  describe "PATCH /services/:id/approve" do
    before { sign_in exec }

    it "approves a service" do
      service = create(:service, status: :pending)
      patch approve_service_path(service)
      expect(service.reload.status).to eq("approved")
    end
  end

  describe "PATCH /services/:id/reject" do
    before { sign_in exec }

    it "rejects a service with a reason" do
      service = create(:service, status: :pending)
      patch reject_service_path(service), params: { service: { rejection_reason: "Not valid" } }
      expect(service.reload.status).to eq("rejected")
      expect(service.rejection_reason).to eq("Not valid")
    end
  end

  describe "GET /services/dashboard" do
    before { sign_in exec }

    it "shows pending services and committee totals" do
      create(:service, status: :pending, committee: "events")
      create(:service, status: :approved, committee: "resources", hours: 5)

      get dashboard_services_path
      expect(response).to have_http_status(:ok)
      expect(assigns(:services).all?(&:pending?)).to be true
      expect(assigns(:committee_totals)["resources"]).to eq(5)
    end
  end
end