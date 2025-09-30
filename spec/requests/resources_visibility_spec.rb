# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Resources visibility", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:category) { ResourceCategory.create!(name: "Docs") }

  # helper to attach a real file (your repo already has spec/fixtures/files/test.pdf)
  def test_pdf
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec/fixtures/files/test.pdf"),
      "application/pdf"
    )
  end

  let!(:pub_pub)  { Resource.create!(name: "Public Doc",  visibility: :public_resource,  published: true,  resource_category: category, file: test_pdf) }
  let!(:mem_pub)  { Resource.create!(name: "Members Doc", visibility: :members_only,     published: true,  resource_category: category, file: test_pdf) }
  let!(:exe_pub)  { Resource.create!(name: "Exec Doc",    visibility: :execs_only,       published: true,  resource_category: category, file: test_pdf) }
  let!(:pub_draft){ Resource.create!(name: "Draft Public",visibility: :public_resource,  published: false, resource_category: category, file: test_pdf) }

  let!(:member) { User.create!(email: "m@example.org", first_name: "Mem", last_name: "Ber", role: :member, status: :active) }
  let!(:exec)   { User.create!(email: "e@example.org", first_name: "Ex",  last_name: "Ec",  role: :exec,   status: :active) }

  it "guest sees only public published resources" do
    get resources_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Public Doc")
    expect(response.body).not_to include("Members Doc")
    expect(response.body).not_to include("Exec Doc")
    expect(response.body).not_to include("Draft Public")
  end

  it "member sees public + members" do
    sign_in member
    get resources_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Public Doc")
    expect(response.body).to include("Members Doc")
    expect(response.body).not_to include("Exec Doc")
  end

  it "exec sees all three visibilities" do
    sign_in exec
    get resources_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Public Doc")
    expect(response.body).to include("Members Doc")
    expect(response.body).to include("Exec Doc")
  end

  it "requires exec for dashboard" do
    # as guest
    get dashboard_resources_path
    expect(response).to have_http_status(302).or have_http_status(:found)

    # as member
    sign_in member
    get dashboard_resources_path
    expect(response).to have_http_status(302).or have_http_status(:found)

    # as exec
    sign_in exec
    get dashboard_resources_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("All Resources")
  end
end

