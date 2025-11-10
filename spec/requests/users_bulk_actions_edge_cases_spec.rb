# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users bulk actions edge cases", type: :request do
     # These tests intentionally omit authentication to confirm redirects
     # since the current app requires login for all user bulk actions.

     let!(:u1) do
          User.create!(
            email: "edge1@example.org",
            first_name: "Edge",
            last_name: "One",
            status: :inactive,
            role: :member,
            graduation_year: 2025,
            major: "Math",
            t_shirt_size: "M",
            password: "password123",
            password_confirmation: "password123"
          )
     end

  let!(:u2) do
       User.create!(
         email: "edge2@example.org",
         first_name: "Edge",
         last_name: "Two",
         status: :inactive,
         role: :member,
         graduation_year: 2026,
         major: "Chem",
         t_shirt_size: "L",
         password: "password123",
         password_confirmation: "password123"
       )
  end

  # Helper to reflect your app’s real redirect path
  def login_path
       "/login"
  end

  describe "GET /users/bulk_edit" do
       it "redirects to login when not authenticated" do
            get bulk_edit_users_path, params: { user_ids: [ u1.id, u2.id ] }
         expect(response).to redirect_to(login_path)
       end

    it "redirects to login when no ids are given" do
         get bulk_edit_users_path, params: { user_ids: [] }
      expect(response).to redirect_to(login_path)
    end
  end

  describe "PATCH /users/bulk_update" do
       it "redirects to login when not authenticated" do
            patch bulk_update_users_path, params: {
              user_ids: [ u1.id, u2.id ],
              bulk_update: {
                status: "",
                graduation_year: "",
                major: "",
                t_shirt_size: ""
              }
            }
         expect(response).to redirect_to(login_path)
       end

    it "redirects to login even if only whitespace values are submitted" do
         patch bulk_update_users_path, params: {
           user_ids: [ u1.id ],
           bulk_update: {
             status: "   ",
             major: "   "
           }
         }
      expect(response).to redirect_to(login_path)
    end

    it "redirects to login when attempting valid updates without auth" do
         patch bulk_update_users_path, params: {
           user_ids: [ u1.id, u2.id ],
           bulk_update: {
             status: "active",
             major: "Physics"
           }
         }
      expect(response).to redirect_to(login_path)
    end
  end

  describe "POST /users/reset_inactive" do
       it "redirects to login when not authenticated" do
            post reset_inactive_users_path
         expect(response).to redirect_to(login_path)
       end
  end
end
