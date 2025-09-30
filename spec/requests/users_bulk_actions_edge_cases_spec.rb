# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Users bulk actions edge cases", type: :request do
  # NOTE: No auth helpers on purpose (current behavior allows access)

  let!(:u1) do
    User.create!(
      email: "edge1@example.org", first_name: "Edge", last_name: "One",
      status: :inactive, role: :member, graduation_year: 2025, major: "Math", t_shirt_size: "M"
    )
  end

  let!(:u2) do
    User.create!(
      email: "edge2@example.org", first_name: "Edge", last_name: "Two",
      status: :inactive, role: :member, graduation_year: 2026, major: "Chem", t_shirt_size: "L"
    )
  end

  describe "GET /users/bulk_edit" do
    it "renders when ids are provided (again, exercising template)" do
      get bulk_edit_users_path, params: { user_ids: [u1.id, u2.id] }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Bulk Edit Users")
      expect(response.body).to include(u1.email, u2.email)
    end

    it "redirects back to index when no ids are given (empty array)" do
      get bulk_edit_users_path, params: { user_ids: [] }
      expect(response).to redirect_to(users_path)
    end
  end

  describe "POST /users/bulk_update" do
    it "ignores BLANK strings (''), leaving fields unchanged" do
      post bulk_update_users_path, params: {
        user_ids: [u1.id, u2.id],
        bulk_update: {
          status: "",                # ignored
          graduation_year: "",       # ignored
          major: "",                 # ignored
          t_shirt_size: ""           # ignored
        }
      }
      expect(response).to redirect_to(users_path)
      expect(u1.reload.status).to eq("inactive")
      expect(u2.reload.status).to eq("inactive")
      expect(u1.graduation_year).to eq(2025)
      expect(u2.graduation_year).to eq(2026)
      expect(u1.major).to eq("Math")
      expect(u2.major).to eq("Chem")
      expect(u1.t_shirt_size).to eq("M")
      expect(u2.t_shirt_size).to eq("L")
    end

    it "also ignores whitespace-only values (present? is false for blank?)" do
      post bulk_update_users_path, params: {
        user_ids: [u1.id],
        bulk_update: {
          status: "   ",            # whitespace -> ignored
          major: "   "
        }
      }
      expect(response).to redirect_to(users_path)
      expect(u1.reload.status).to eq("inactive")
      expect(u1.major).to eq("Math")
    end

    it "updates multiple provided fields at once (happy path, again)" do
      post bulk_update_users_path, params: {
        user_ids: [u1.id, u2.id],
        bulk_update: {
          status: "active",
          major:  "Physics",
          # graduation_year omitted -> unchanged
          # t_shirt_size omitted     -> unchanged
        }
      }
      expect(response).to redirect_to(users_path)
      expect(u1.reload.status).to eq("active")
      expect(u2.reload.status).to eq("active")
      expect(u1.major).to eq("Physics")
      expect(u2.major).to eq("Physics")
      expect(u1.graduation_year).to eq(2025)
      expect(u2.graduation_year).to eq(2026)
      expect(u1.t_shirt_size).to eq("M")
      expect(u2.t_shirt_size).to eq("L")
    end
  end

  describe "POST /users/reset_inactive" do
    it "is a no-op when there are no inactive users" do
      User.update_all(status: :active)
      post reset_inactive_users_path
      expect(response).to redirect_to(users_path)
      expect(User.where(status: :inactive).count).to eq(0)
      expect(User.where(status: :active).count).to be >= 2
    end
  end
end

