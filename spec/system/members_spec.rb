# spec/system/members_spec.rb
require "rails_helper"

RSpec.describe "Users bulk actions", type: :system do
  include Warden::Test::Helpers

  before(:each) do
    driven_by(:rack_test) # no real browser needed
    Warden.test_mode!
  end

  after(:each) do
    Warden.test_reset!
  end

  let!(:exec) do
    User.create!(
      email: "exec@example.org",
      first_name: "Exec",
      last_name:  "User",
      status: :active,
      role:   :exec
    )
  end

  let!(:u1) do
    User.create!(
      email: "member1@example.org",
      first_name: "Member",
      last_name:  "One",
      status: :active,
      role:   :member
    )
  end

  let!(:u2) do
    User.create!(
      email: "member2@example.org",
      first_name: "Member",
      last_name:  "Two",
      status: :inactive,
      role:   :member
    )
  end

  it "GET /users/bulk_edit with selected ids renders the page" do
    login_as(exec, scope: :user)

    visit users_path

    # Select the two user checkboxes by value and toggle them directly.
    find(:css, "input.user-checkbox[value='#{u1.id}']", visible: :all).set(true)
    find(:css, "input.user-checkbox[value='#{u2.id}']", visible: :all).set(true)

    click_button "Edit Selected Users"

    # The page has query params (user_ids[]=...), so ignore them in the path assertion.
    expect(page).to have_current_path(bulk_edit_users_path, ignore_query: true)
    expect(page).to have_selector("form")
  end
end

# Request specs for controller behavior (no browser needed)
RSpec.describe "Users bulk actions (requests)", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:exec) do
    User.create!(
      email: "exec2@example.org",
      first_name: "Exec",
      last_name:  "Two",
      status: :active,
      role:   :exec
    )
  end

  let!(:member_a) do
    User.create!(
      email: "req_member_a@example.org",
      first_name: "Req",
      last_name:  "A",
      status: :active,
      role:   :member,
      graduation_year: 2026,
      major: "Biology",
      t_shirt_size: "M"
    )
  end

  let!(:member_b) do
    User.create!(
      email: "req_member_b@example.org",
      first_name: "Req",
      last_name:  "B",
      status: :inactive,
      role:   :member,
      graduation_year: 2025,
      major: "Business",
      t_shirt_size: "L"
    )
  end

  it "POST /users/bulk_update updates only provided fields" do
    sign_in exec

    post bulk_update_users_path, params: {
      user_ids: [member_a.id, member_b.id],
      bulk_update: {
        status: "active" # provided → should update
        # other fields omitted → should NOT change
      }
    }

    expect(response).to redirect_to(users_path)

    expect(member_a.reload.status).to eq("active")
    expect(member_b.reload.status).to eq("active")

    # untouched fields remain as they were
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

