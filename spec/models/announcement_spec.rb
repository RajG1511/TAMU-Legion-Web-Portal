require 'rails_helper'

RSpec.describe Announcement, type: :model do
     describe ".current" do
          it "returns the first announcement if it exists" do
               ann = Announcement.create!(message: "Hello")
            expect(Announcement.current).to eq(ann)
          end

       it "creates a new announcement if none exists" do
            expect { Announcement.current }.to change { Announcement.count }.by(1)
         expect(Announcement.current.message).to be_nil
       end
     end
end
