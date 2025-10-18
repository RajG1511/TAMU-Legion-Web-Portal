# frozen_string_literal: true
require "rails_helper"

RSpec.describe "users/index", type: :view do
  it "renders bulk edit form with user_id checkboxes and the reset button for execs" do
    exec = User.create!(email: "view_exec@example.org", first_name: "View", last_name: "Exec", role: :exec, status: :active)
    u1   = User.create!(email: "view1@example.org", first_name: "View", last_name: "One",  role: :member, status: :active)
    u2   = User.create!(email: "view2@example.org", first_name: "View", last_name: "Two",  role: :member, status: :inactive)

    assign(:users, [u1, u2])

    # stub current_user in the view so the Reset button branch renders
    allow(view).to receive(:current_user).and_return(exec)

    render template: "users/index"

    # Bulk-edit form and submit
    expect(rendered).to include(%(action="#{bulk_edit_users_path}"))
    expect(rendered).to include("Edit Selected Users")

    # Checkboxes for users (name='user_ids[]')
    expect(rendered.scan(/name="user_ids\[\]".*value="#{u1.id}"/).any?).to be true
    expect(rendered.scan(/name="user_ids\[\]".*value="#{u2.id}"/).any?).to be true

    # Reset All Inactive button (only for execs)
    expect(rendered).to include(%(action="#{reset_inactive_users_path}"))
  end

  it "hides the reset button for non-execs but still shows bulk form" do
    member = User.create!(email: "view_mem@example.org", first_name: "View", last_name: "Mem", role: :member, status: :active)
    assign(:users, [member])

    allow(view).to receive(:current_user).and_return(member)

    render template: "users/index"

    expect(rendered).to include(%(action="#{bulk_edit_users_path}"))
    expect(rendered).to include("Edit Selected Users")
    expect(rendered).not_to include(%(action="#{reset_inactive_users_path}"))
  end
end

