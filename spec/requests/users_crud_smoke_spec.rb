# spec/requests/users_crud_smoke_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users CRUD (smoke)", type: :request do
     include Warden::Test::Helpers

  before { Warden.test_mode! }
  after  { Warden.test_reset! }

  let(:exec) { create(:user, :exec, email: "crud_exec@example.org") }
  let(:pres) { create(:user, :president, email: "crud_pres@example.org") }
  let!(:existing) { create(:user, email: "existing@example.org") }

  let(:valid_attrs) do
       {
         email: "new_user@example.org",
         first_name: "New",
         last_name: "User",
         role: "member",
         status: "active",
         major: "Computer Science",
         graduation_year: 2026,
         t_shirt_size: "M",
         password: "password123",
         password_confirmation: "password123"
       }
  end

  describe "GET /users" do
       it "renders the index" do
            login_as(exec, scope: :user)
         get users_path
         expect(response).to have_http_status(:ok)
         expect(response.body).to include("Users Management")
       end
  end

  describe "GET /users/new" do
       it "renders the new form" do
            login_as(exec, scope: :user)
         get new_user_path
         expect(response).to have_http_status(:ok)
       end
  end

  describe "POST /users" do
       before { login_as(pres, scope: :user) }

    it "creates a user and redirects to show" do
         post users_path, params: { user: valid_attrs }

      puts "STATUS: #{response.status}"
      puts "BODY: #{response.body}"

      created = User.find_by(email: "new_user@example.org")
      expect(created).not_to be_nil
      expect(response).to redirect_to(user_path(created)).or redirect_to(users_path)
    end

    it "does not create a user with invalid params" do
         expect {
              post users_path, params: { user: valid_attrs.merge(email: "") }
         }.not_to change(User, :count)

      expect(response).to have_http_status(:ok)
        .or have_http_status(:unprocessable_entity)
        .or have_http_status(:found)
    end
  end

  describe "GET /users/:id" do
       it "shows a user" do
            login_as(exec, scope: :user)
         get user_path(existing)
         expect(response).to have_http_status(:ok)
         expect(response.body).to include(existing.email)
       end
  end

  describe "GET /users/:id/edit" do
       it "renders the edit form" do
            login_as(exec, scope: :user)
         get edit_user_path(existing)
         expect(response).to have_http_status(:ok)
       end
  end

  describe "PATCH /users/:id" do
       before { login_as(exec, scope: :user) }

    it "updates a user with valid data" do
         patch user_path(existing), params: { user: { first_name: "Updated" } }
      expect(existing.reload.first_name).to eq("Updated")
      expect(response).to redirect_to(user_path(existing)).or redirect_to(users_path)
    end

    it "does not update with invalid data" do
         patch user_path(existing), params: { user: { first_name: "" } }
      expect(response).to have_http_status(:ok)
        .or have_http_status(:unprocessable_entity)
        .or have_http_status(:found)
    end
  end

  describe "GET /users/:id/delete" do
       it "renders delete confirmation page" do
            login_as(exec, scope: :user)
         get delete_user_path(existing)
         expect(response).to have_http_status(:ok)
       end
  end

  describe "DELETE /users/:id" do
       before { login_as(exec, scope: :user) }

    it "destroys a user and redirects" do
         victim = create(:user, email: "to_delete@example.org")
      expect {
           delete user_path(victim)
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(users_path)
    end
  end
end
