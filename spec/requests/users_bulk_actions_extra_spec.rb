require "rails_helper"

RSpec.describe "Users bulk actions (extra)", type: :request do
     include Devise::Test::IntegrationHelpers

  let!(:exec) do
       User.create!(
         email: "extra_exec@example.org",
         password: "password123",      # Devise requires password for sign_in
         first_name: "Exec",
         last_name:  "User",
         status: :active,
         role:   :exec
       )
  end

  let!(:m1) do
       User.create!(
         email: "extra_member1@example.org",
         password: "password123",
         first_name: "Alpha",
         last_name:  "One",
         status: :inactive,
         role:   :member,
         graduation_year: 2026,
         major: "Biology",
         t_shirt_size: "S"
       )
  end

  let!(:m2) do
       User.create!(
         email: "extra_member2@example.org",
         password: "password123",
         first_name: "Beta",
         last_name:  "Two",
         status: :active,
         role:   :member,
         graduation_year: 2025,
         major: "Business",
         t_shirt_size: "M"
       )
  end

  describe "GET /users/bulk_edit" do
       it "renders when ids are provided" do
            sign_in exec, scope: :user

         get bulk_edit_users_path, params: { user_ids: [ m1.id, m2.id ] }

         expect(response).to have_http_status(:ok)
         expect(response.body).to include('name="user_ids[]"')
         expect(response.body).to include(m1.id.to_s)
         expect(response.body).to include(m2.id.to_s)
       end

    it "redirects back to index when no ids given" do
         sign_in exec, scope: :user

      get bulk_edit_users_path

      expect(response).to redirect_to(users_path)
    end
  end

  describe "POST /users/bulk_update" do
       it "updates multiple provided fields and leaves others unchanged" do
            sign_in exec

         patch bulk_update_users_path, params: {
           user_ids: [ m1.id, m2.id ],
           bulk_update: {
             status: "active",
             graduation_year: "2027",
             major: "Computer Science",
             t_shirt_size: "L"
           }
         }

         expect(response).to redirect_to(users_path)

         [ m1, m2 ].each(&:reload)
         expect(m1.status).to eq("active")
         expect(m2.status).to eq("active")
         expect(m1.graduation_year).to eq(2027)
         expect(m2.graduation_year).to eq(2027)
         expect(m1.major).to eq("Computer Science")
         expect(m2.major).to eq("Computer Science")
         expect(m1.t_shirt_size).to eq("L")
         expect(m2.t_shirt_size).to eq("L")
       end

    it "does nothing when no user_ids are passed" do
         sign_in exec

      original = [ m1.attributes, m2.attributes ]

      patch bulk_update_users_path, params: {
        # user_ids omitted on purpose
        bulk_update: { status: "active" }
      }

      expect(response).to redirect_to(users_path)

      [ m1.reload, m2.reload ]
      expect(m1.status).to eq(original[0]["status"])
      expect(m2.status).to eq(original[1]["status"])
    end

    it "ignores blank fields (does not overwrite existing data with blanks)" do
         sign_in exec

      patch bulk_update_users_path, params: {
        user_ids: [ m1.id ],
        bulk_update: {
          status: "",                # blank
          graduation_year: "",       # blank
          major: "",                 # blank
          t_shirt_size: ""           # blank
        }
      }

      expect(response).to redirect_to(users_path)

      expect(m1.reload.status).to eq("inactive")        # unchanged
      expect(m1.graduation_year).to eq(2026)            # unchanged
      expect(m1.major).to eq("Biology")                 # unchanged
      expect(m1.t_shirt_size).to eq("S")                # unchanged
    end
  end


  describe "POST /users/reset_inactive" do
       it "activates any inactive users" do
            sign_in exec, scope: :user
         expect(User.where(status: :inactive).count).to be >= 1

         post reset_inactive_users_path

         expect(response).to redirect_to(users_path)
         expect(User.where(status: :inactive).count).to eq(0)
       end

    it "is a no-op when there are no inactive users" do
         sign_in exec, scope: :user
      User.update_all(status: :active)

      post reset_inactive_users_path

      expect(response).to redirect_to(users_path)
      expect(User.where(status: :inactive).count).to eq(0)
      expect(User.where(status: :active).count).to be >= 3
    end
  end
end
