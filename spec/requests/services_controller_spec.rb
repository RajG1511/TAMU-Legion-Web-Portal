require 'rails_helper'

RSpec.describe ServicesController, type: :request do
  include Devise::Test::IntegrationHelpers

  let(:member) { create(:user, role: :member) }
  let(:exec)   { create(:user, :exec) }

  let!(:brotherhood) { create(:committee, name: "Brotherhood") }
  let!(:social) { create(:committee, name: "Social") }

  describe "GET /services" do
    context "as a member" do
      before { sign_in member, scope: :user }

      it "shows only their own services" do
        own_service = create(:service, user: member, committee: brotherhood)
        other_service = create(:service, committee: social) # someone else

        get services_path
        expect(response).to have_http_status(:ok)
        expect(assigns(:services)).to include(own_service)
        expect(assigns(:services)).not_to include(other_service)
      end
    end

    context "as an exec" do
      before { sign_in exec, scope: :user }

      it "shows all services" do
        service1 = create(:service, committee: brotherhood)
        service2 = create(:service, committee: social)

        get services_path
        expect(assigns(:services)).to match_array([service1, service2])
      end
    end
  end

  describe "GET /services/new" do
    before { sign_in member, scope: :user }

    it "renders the new service form" do
      get new_service_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Submit a Service Request")
    end
  end

  describe "GET /services/my_services" do
    before { sign_in member, scope: :user }

    it "shows the user's own services paginated" do
      create_list(:service, 12, user: member, committee: brotherhood)
      get services_path
      expect(response).to have_http_status(:ok)
      expect(assigns(:services).count).to eq(12) # paginated
    end
  end

  describe "POST /services" do
    before { sign_in member, scope: :user }

    context "with valid params" do
      it "creates a new service request" do
        expect {
          post services_path, params: { service: attributes_for(:service, committee_id: brotherhood.id) }
        }.to change(Service, :count).by(1)

        expect(response).to redirect_to(services_path)
        follow_redirect!
        expect(response.body).to include("Service request submitted.")
      end
    end

    context "with invalid params" do
      it "renders new with errors" do
        expect {
          post services_path, params: { service: attributes_for(:service, name: nil, committee_id: brotherhood.id) }
        }.not_to change(Service, :count)

        expect(response.body).to include("Please fill out all required fields.")
      end
    end
  end

  describe "PATCH /services/:id/approve" do
    before { sign_in exec, scope: :user }

    it "approves a service" do
      service = create(:service, status: :pending, committee: brotherhood)
      patch approve_service_path(service)
      expect(service.reload.status).to eq("approved")
    end
  end

  describe "PATCH /services/:id/reject" do
    before { sign_in exec, scope: :user }

    it "rejects a service with a reason" do
      service = create(:service, status: :pending, committee: brotherhood)
      patch reject_service_path(service), params: { service: { rejection_reason: "Not valid" } }
      service.reload
      expect(service.status).to eq("rejected")
      expect(service.rejection_reason).to eq("Not valid")
    end

    it "handles rejection failure gracefully" do
      service = create(:service, status: :pending, committee: brotherhood)
      allow_any_instance_of(Service).to receive(:update).and_return(false)

      patch reject_service_path(service), params: { service: { rejection_reason: "Fail" } }
      expect(response).to redirect_to(dashboard_services_path)
      expect(flash[:alert]).to include("Rejection failed")
    end
  end

  describe "GET /services/dashboard" do
    before { sign_in exec, scope: :user }

    it "shows pending services and committee totals" do
      create(:service, status: :pending, committee: brotherhood, hours: 3)
      create(:service, status: :pending, committee: social, hours: 5)
      create(:service, status: :approved, committee: brotherhood, hours: 3)
      create(:service, status: :approved, committee: social, hours: 5)

      get dashboard_services_path
      expect(response).to have_http_status(:ok)
      expect(assigns(:services).all?(&:pending?)).to be true
      expect(assigns(:committee_totals)[brotherhood.name]).to eq(3)
      expect(assigns(:committee_totals)[social.name]).to eq(5)
    end
  end

  describe "Authorization for exec-only actions" do
    before { sign_in member, scope: :user }

    it "prevents members from approving" do
      service = create(:service, status: :pending, committee: brotherhood)
      patch approve_service_path(service)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it "prevents members from rejecting" do
      service = create(:service, status: :pending, committee: brotherhood)
      patch reject_service_path(service), params: { service: { rejection_reason: "Fail" } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it "prevents members from viewing dashboard" do
      get dashboard_services_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end
  end
end
