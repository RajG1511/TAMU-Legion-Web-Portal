# spec/system/members_spec.rb
require "rails_helper"

RSpec.describe "Users bulk actions", type: :system do
     include Warden::Test::Helpers

  before(:each) { Warden.test_mode! }
  after(:each)  { Warden.test_reset! }

  before { driven_by(:rack_test) }

  let!(:exec) { create(:user, :exec, email: "exec@example.org", password: "password123") }
  let!(:u1)   { create(:user, email: "member1@example.org", password: "password123") }
  let!(:u2)   { create(:user, email: "member2@example.org", password: "password123") }

  it "renders the bulk edit page after selecting users" do
       login_as(exec, scope: :user)

    # Directly visit the bulk_edit page with selected user IDs
    visit bulk_edit_users_path(user_ids: [ u1.id, u2.id ])

    expect(page).to have_current_path(bulk_edit_users_path, ignore_query: true)
    expect(page).to have_selector("form")
  end

  it "renders the bulk edit page even if only one user is selected" do
       login_as(exec, scope: :user)

    visit bulk_edit_users_path(user_ids: [ u1.id ])

    expect(page).to have_current_path(bulk_edit_users_path, ignore_query: true)
    expect(page).to have_selector("form")
  end

  it "redirects or shows an error if no users are selected" do
       login_as(exec, scope: :user)

    # visiting without any user_ids simulates no selection
    visit bulk_edit_users_path

    # Expect some kind of notice/error message (adjust depending on your controller)
    expect(page).to have_content("No users selected for bulk edit").or have_current_path(users_path)
  end
end
