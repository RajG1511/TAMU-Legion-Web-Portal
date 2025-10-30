require "rails_helper"

RSpec.describe "Users bulk actions param paths", type: :request do
     include Warden::Test::Helpers

  before(:each) { Warden.test_mode! }
  after(:each)  { Warden.test_reset! }

  let!(:exec) { create(:user, :exec, email: "params_exec@example.org") }

  let!(:a) do
       create(:user, :inactive,
         email: "params_member_a@example.org",
         first_name: "A",
         last_name: "One",
         graduation_year: 2026,
         major: "Biology",
         t_shirt_size: "S"
       )
  end

  let!(:b) do
       create(:user,
         email: "params_member_b@example.org",
         first_name: "B",
         last_name: "Two",
         graduation_year: 2025,
         major: "Business",
         t_shirt_size: "M"
       )
  end

  before(:each) do
       # Log in exec user using Warden
       login_as(exec, scope: :user)
  end

  it "updates only status when only status is provided" do
       patch bulk_update_users_path, params: {
         user_ids: [ a.id, b.id ],
         bulk_update: { status: "active" }
       }

    expect(response).to redirect_to(users_path)

    [ a, b ].each { |u| expect(u.reload.status).to eq("active") }
    expect(a.reload.graduation_year).to eq(2026)
    expect(b.reload.graduation_year).to eq(2025)
    expect(a.reload.major).to eq("Biology")
    expect(b.reload.major).to eq("Business")
    expect(a.reload.t_shirt_size).to eq("S")
    expect(b.reload.t_shirt_size).to eq("M")
  end

  it "updates only graduation_year when that is provided" do
       patch bulk_update_users_path, params: {
         user_ids: [ a.id, b.id ],
         bulk_update: { graduation_year: "2027" }
       }

    expect(response).to redirect_to(users_path)

    [ a, b ].each { |u| expect(u.reload.graduation_year).to eq(2027) }
    expect(a.reload.status).to eq("inactive")
    expect(b.reload.status).to eq("active")
    expect(a.reload.major).to eq("Biology")
    expect(b.reload.major).to eq("Business")
    expect(a.reload.t_shirt_size).to eq("S")
    expect(b.reload.t_shirt_size).to eq("M")
  end

  it "updates only major when that is provided" do
       patch bulk_update_users_path, params: {
         user_ids: [ a.id, b.id ],
         bulk_update: { major: "Computer Science" }
       }

    expect(response).to redirect_to(users_path)

    [ a, b ].each { |u| expect(u.reload.major).to eq("Computer Science") }
    expect(a.reload.status).to eq("inactive")
    expect(b.reload.status).to eq("active")
    expect(a.reload.graduation_year).to eq(2026)
    expect(b.reload.graduation_year).to eq(2025)
    expect(a.reload.t_shirt_size).to eq("S")
    expect(b.reload.t_shirt_size).to eq("M")
  end

  it "updates only t_shirt_size when that is provided" do
       patch bulk_update_users_path, params: {
         user_ids: [ a.id, b.id ],
         bulk_update: { t_shirt_size: "L" }
       }

    expect(response).to redirect_to(users_path)

    [ a, b ].each { |u| expect(u.reload.t_shirt_size).to eq("L") }
    expect(a.reload.status).to eq("inactive")
    expect(b.reload.status).to eq("active")
    expect(a.reload.graduation_year).to eq(2026)
    expect(b.reload.graduation_year).to eq(2025)
    expect(a.reload.major).to eq("Biology")
    expect(b.reload.major).to eq("Business")
  end
end
