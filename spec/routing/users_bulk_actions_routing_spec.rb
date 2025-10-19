# spec/requests/users_bulk_actions_routing_spec.rb
# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Users bulk actions routing", type: :routing do
  it "routes PATCH /users/bulk_update -> users#bulk_update" do
    expect(patch: "/users/bulk_update").to route_to("users#bulk_update")
  end

  it "routes GET /users/bulk_edit -> users#bulk_edit" do
    expect(get: "/users/bulk_edit").to route_to("users#bulk_edit")
  end

  it "routes POST /users/reset_inactive -> users#reset_inactive" do
    expect(post: "/users/reset_inactive").to route_to("users#reset_inactive")
  end
end
