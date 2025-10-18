require 'rails_helper'

RSpec.describe Committee, type: :model do
  describe "validations" do
    it "is invalid without a name" do
      committee = Committee.new
      expect(committee).not_to be_valid
      expect(committee.errors[:name]).to be_present
    end

    it "requires a unique name" do
      Committee.create(name: "Committee 1")
      dupe = Committee.new(name: "Committee 1")
      expect(dupe).not_to be_valid
      expect(dupe.errors[:name]).to be_present
    end
  end

  describe "associations" do
    it 'can have users through committee_memberships' do
      committee = Committee.create!(name: 'Service')
      user = User.create!(
        email: "member1@org.edu",
        first_name: "Member",
        last_name: "1",
        graduation_year: 2024,
        major: "Computer Science",
        t_shirt_size: "S",
        status: :active,
        role: :member
      )

      CommitteeMembership.create!(committee: committee, user: user)
      expect(committee.users).to include(user)
    end

    it 'destroys dependent memberships when destroyed' do
      committee = Committee.create!(name: 'Service')
      user = User.create!(
        email: "member1@org.edu",
        first_name: "Member",
        last_name: "1",
        graduation_year: 2024,
        major: "Computer Science",
        t_shirt_size: "S",
        status: :active,
        role: :member
      )

      CommitteeMembership.create!(committee: committee, user: user)
      expect { committee.destroy }.to change { CommitteeMembership.count }.by(-1)
    end
  end
end
