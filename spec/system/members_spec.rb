# spec/system/members_spec.rb
require "rails_helper"

# -------------------------
# System specs for bulk edit UI
# -------------------------
RSpec.describe "Users bulk actions", type: :system do
     include Warden::Test::Helpers

  before(:each) { Warden.test_mode! }
  after(:each)  { Warden.test_reset! }

  before { driven_by(:rack_test) }

  let!(:exec) { create(:user, :exec, email: "exec@example.org", password: "password123") }
  let!(:u1)   { create(:user, email: "member1@example.org", password: "password123") }
  let!(:u2)   { create(:user, :inactive, email: "member2@example.org", password: "password123") }

  it "GET /users/bulk_edit with selected ids renders the page" do
       login_as(exec, scope: :user)

    visit users_path

    # select checkboxes for the users
    find(:css, "input.user-checkbox[value='#{u1.id}']", visible: :all).set(true)
    find(:css, "input.user-checkbox[value='#{u2.id}']", visible: :all).set(true)

    click_button "Edit Selected Users"

    expect(page).to have_current_path(bulk_edit_users_path, ignore_query: true)
    expect(page).to have_selector("form")
  end
end

# -------------------------
# Request specs for controller actions
# -------------------------
RSpec.describe "Users bulk actions (requests)", type: :request do
     include Devise::Test::IntegrationHelpers

  let!(:exec)     { create(:user, :exec, email: "exec2@example.org") }
  let!(:member_a) { create(:user, email: "req_member_a@example.org", graduation_year: 2026, major: "Biology", t_shirt_size: "M") }
  let!(:member_b) { create(:user, :inactive, email: "req_member_b@example.org", graduation_year: 2025, major: "Business", t_shirt_size: "L") }

  it "PATCH /users/bulk_update updates only provided fields" do
       sign_in exec

    patch bulk_update_users_path, params: {
      user_ids: [ member_a.id, member_b.id ],
      bulk_update: { status: "active" } # only update status
    }

    expect(response).to redirect_to(users_path)

    # Ensure status is updated
    expect(member_a.reload.status).to eq("active")
    expect(member_b.reload.status).to eq("active")

    # Ensure untouched fields remain the same
    expect(member_a.reload.graduation_year).to eq(2026)
    expect(member_b.reload.graduation_year).to eq(2025)
    expect(member_a.reload.major).to eq("Biology")
    expect(member_b.reload.major).to eq("Business")
    expect(member_a.reload.t_shirt_size).to eq("M")
    expect(member_b.reload.t_shirt_size).to eq("L")
  end

  it "POST /users/reset_inactive sets all inactive users to active" do
       sign_in exec

    expect(User.where(status: :inactive).count).to be >= 1
    expect(User.where(status: :active).count).to be >= 1

    post reset_inactive_users_path

    expect(response).to redirect_to(users_path)
    expect(User.where(status: :inactive).count).to eq(0)
  end
end
