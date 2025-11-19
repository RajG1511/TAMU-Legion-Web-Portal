# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
     it "exposes role/status we rely on (exec? predicate and status predicates)" do
          exec = create(:user, email: "enum_exec@example.org", first_name: "E", last_name: "X", role: :exec, status: :active)
       mem  = create(:user, email: "enum_mem@example.org",  first_name: "M", last_name: "M", role: :member, status: :inactive)

       # Role predicates
       expect(exec.exec?).to be true
       expect(mem.exec?).to be false

       # Status predicates
       expect(exec.active?).to be true
       expect(mem.inactive?).to be true

       # Stored enum/string values
       expect(exec.role).to eq("exec")
       expect(mem.role).to eq("member")
       expect(exec.status).to eq("active")
       expect(mem.status).to eq("inactive")
     end

  it "has working scopes used by reset_inactive" do
       u1 = create(:user, email: "s1@example.org", first_name: "S", last_name: "1", status: :inactive, role: :member)
    u2 = create(:user, email: "s2@example.org", first_name: "S", last_name: "2", status: :inactive, role: :member)
    u3 = create(:user, email: "s3@example.org", first_name: "S", last_name: "3", status: :active,   role: :member)

    expect(User.inactive.pluck(:id)).to match_array([ u1.id, u2.id ])
    expect(User.active.pluck(:id)).to include(u3.id)
  end
end
