require 'rails_helper'

RSpec.describe Committee, type: :model do
     describe "validations" do
          it "is invalid without a name" do
               committee = Committee.new
            expect(committee).not_to be_valid
            expect(committee.errors[:name]).to be_present
          end

       it "requires a unique name" do
            Committee.create!(name: "Committee 1")
         dupe = Committee.new(name: "Committee 1")
         expect(dupe).not_to be_valid
         expect(dupe.errors[:name]).to be_present
       end
     end

  describe "associations" do
       let(:committee) { Committee.create!(name: 'Service') }
    let(:user) { create(:user, role: :member) } # uses FactoryBot

    it 'can have users through committee_memberships' do
         CommitteeMembership.create!(committee: committee, user: user)
      expect(committee.users).to include(user)
    end

    it 'destroys dependent memberships when destroyed' do
         CommitteeMembership.create!(committee: committee, user: user)
      expect { committee.destroy }.to change { CommitteeMembership.count }.by(-1)
    end
  end
end
