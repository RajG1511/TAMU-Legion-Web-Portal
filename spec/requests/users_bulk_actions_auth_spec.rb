# spec/requests/users_bulk_actions_auth_spec.rb
require "rails_helper"

# NOTE:
# These are characterization tests that document CURRENT behavior:
# - bulk_edit/bulk_update/reset_inactive are accessible even when not signed in
# - non-exec users can access and perform updates
# If/when you add proper before_actions/authorization, update these examples
# to assert redirects/forbidden instead.

RSpec.describe "Users bulk actions auth", type: :request do
     include Warden::Test::Helpers

  before(:each) { Warden.test_mode! }
  after(:each)  { Warden.test_reset! }

  let!(:u1) do
       User.create!(
         email: "auth_member1@example.org",
         first_name: "Mem",
         last_name: "One",
         status: :inactive,
         role: :member,
         password: "password123",
         password_confirmation: "password123"
       )
  end

  let!(:u2) do
       User.create!(
         email: "auth_member2@example.org",
         first_name: "Mem",
         last_name: "Two",
         status: :inactive,
         role: :member,
         password: "password123",
         password_confirmation: "password123"
       )
  end

  let!(:non_exec) do
       User.create!(
         email: "plain_user@example.org",
         first_name: "Plain",
         last_name: "User",
         status: :active,
         role: :member,
         password: "password123",
         password_confirmation: "password123"
       )
  end

  describe "when not signed in" do
       it "renders bulk_edit (no redirect currently)" do
            get bulk_edit_users_path, params: { user_ids: [ u1.id, u2.id ] }
         expect(response).to have_http_status(200)
         expect(response.body).to include("Bulk Edit Users")
         expect(response.body).to include(%(name="user_ids[]"))
         expect(response.body).to include(%(action="/users/bulk_update"))
       end

    it "allows bulk_update (updates happen)" do
         patch bulk_update_users_path, params: {
           user_ids: [ u1.id, u2.id ],
           bulk_update: { status: "active" }
         }
      expect(response).to redirect_to(users_path)
      expect(u1.reload.status).to eq("active")
      expect(u2.reload.status).to eq("active")
    end

    it "allows reset_inactive (activates any inactive users)" do
         expect(User.where(status: :inactive).count).to be >= 1
      post reset_inactive_users_path
      expect(response).to redirect_to(users_path)
      expect(User.where(status: :inactive).count).to eq(0)
    end
  end

  describe "when signed in as a non-exec user" do
       before { login_as(non_exec, scope: :user) }

    it "can access bulk_edit" do
         get bulk_edit_users_path, params: { user_ids: [ u1.id ] }
      expect(response).to have_http_status(200)
      expect(response.body).to include("Bulk Edit Users")
      expect(response.body).to include(%(name="user_ids[]"))
      expect(response.body).to include(%(action="/users/bulk_update"))
    end

    it "can perform bulk_update" do
         patch bulk_update_users_path, params: {
           user_ids: [ u1.id ],
           bulk_update: { status: "active" }
         }
      expect(response).to redirect_to(users_path)
      expect(u1.reload.status).to eq("active")
    end

    it "can call reset_inactive" do
         u2.update!(status: :inactive)
      post reset_inactive_users_path
      expect(response).to redirect_to(users_path)
      expect(User.where(status: :inactive).count).to eq(0)
    end
  end
end
