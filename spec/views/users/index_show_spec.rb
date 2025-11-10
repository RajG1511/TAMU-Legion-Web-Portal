# frozen_string_literal: true
require "rails_helper"

RSpec.describe "users/directory", type: :view do
  let(:exec) { create(:user, :exec) }
  let(:member) { create(:user) }
  let(:u1) { create(:user, first_name: "Alice", last_name: "Smith") }
  let(:u2) { create(:user, first_name: "Bob", last_name: "Jones", status: :inactive) }

  context "when rendering the member directory" do
    it "renders the search form and profile link for current_user" do
      assign(:users, [u1, u2])
      allow(view).to receive(:current_user).and_return(member)

      render template: "users/directory"

      # Search form
      expect(rendered).to include("Search For:")
      expect(rendered).to include('name="q"')
      expect(rendered).to include("Search")

      # View My Profile button
      expect(rendered).to include("View My Profile")
      expect(rendered).to include(user_path(member))
    end

    it "renders all users in the table with correct columns" do
      assign(:users, [u1, u2])
      allow(view).to receive(:current_user).and_return(member)

      render template: "users/directory"

      [u1, u2].each do |u|
        expect(rendered).to include("#{u.first_name} #{u.last_name}")
        expect(rendered).to include(u.email)
        expect(rendered).to include(u.role.to_s.titleize)
        expect(rendered).to include(u.position.presence || "-")
        expect(rendered).to include(u.major.presence || "-")
        expect(rendered).to include(u.graduation_year.to_s)
      end
    end

    it "renders a placeholder row if no users are present" do
      assign(:users, [])
      allow(view).to receive(:current_user).and_return(member)

      render template: "users/directory"

      expect(rendered).to include("No members matched your search.")
      expect(rendered).to include(member_directory_path)
    end
  end
end

# frozen_string_literal: true
require "rails_helper"
require "ostruct"

RSpec.describe "users/show", type: :view do
  let(:exec) { create(:user, :exec) }
  let(:member) { create(:user, first_name: "Test", last_name: "User", major: "CS", graduation_year: 2026, t_shirt_size: "M") }
  let(:approved_hours) { 12.5 }
  let(:services) do
    [
      OpenStruct.new(
        name: "Event 1",
        committee: OpenStruct.new(name: "Committee A"),
        status: "approved",
        hours: 3.0,
        date_performed: Date.new(2025, 5, 1)
      ),
      OpenStruct.new(
        name: "Event 2",
        committee: nil,
        status: "pending",
        hours: 2.5,
        date_performed: Date.new(2025, 6, 1)
      )
    ]
  end

  before do
    assign(:user, member)
    assign(:approved_hours, approved_hours)
    assign(:services, services)
    allow(view).to receive(:current_user).and_return(exec)
  end

  it "renders user basic info" do
    render template: "users/show"

    expect(rendered).to include(member.full_name)
    expect(rendered).to include(member.email)
    expect(rendered).to include(member.role.humanize)
    expect(rendered).to include(member.position.presence || "None")
    expect(rendered).to include(member.major)
    expect(rendered).to include(member.graduation_year.to_s)
    expect(rendered).to include(member.status.humanize)
    expect(rendered).to include(member.t_shirt_size)
    expect(rendered).to include("#{approved_hours} Hours of Service")
    expect(rendered).to include(member.created_at.strftime("%B %d, %Y"))
  end

  it "renders service history table" do
    render template: "users/show"

    services.each do |s|
      expect(rendered).to include(s.name)
      expect(rendered).to include(s.committee&.name || "-")
      expect(rendered).to include(s.status.humanize)
      expect(rendered).to include(sprintf("%.1f", s.hours))
      expect(rendered).to include(s.date_performed.strftime("%m/%d/%y"))
    end
  end

  it "renders a message if no services are available" do
    assign(:services, [])
    render template: "users/show"

    expect(rendered).to include("No service history available.")
  end

  it "renders the back and edit buttons for exec users" do
    render template: "users/show"

    expect(rendered).to include("← Back")
    expect(rendered).to include(edit_user_path(member))
  end
end
