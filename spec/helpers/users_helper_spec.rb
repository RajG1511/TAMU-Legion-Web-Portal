require "rails_helper"

RSpec.describe UsersHelper, type: :helper do
     describe "#version_actor_name" do
          it "returns actor full_name when actor is present" do
               actor = double("Actor", full_name: "Actor Name")
            v = double("Version", actor: actor)
            allow(v).to receive(:respond_to?).with(:actor).and_return(true)
            allow(v).to receive(:try).with(:actor).and_return(actor)
            expect(helper.version_actor_name(v)).to eq("Actor Name")
          end

       it "returns updated_by when present" do
            v = double("Version", updated_by: "Updater")
         allow(v).to receive(:respond_to?).with(:actor).and_return(false)
         allow(v).to receive(:respond_to?).with(:updated_by).and_return(true)
         allow(v).to receive(:try).with(:updated_by).and_return("Updater")
         expect(helper.version_actor_name(v)).to eq("Updater")
       end

       it "returns user full_name when present" do
            user = double("User", full_name: "User Name")
         v = double("Version", user: user)
         allow(v).to receive(:respond_to?).with(:actor).and_return(false)
         allow(v).to receive(:respond_to?).with(:updated_by).and_return(false)
         allow(v).to receive(:respond_to?).with(:user).and_return(true)
         allow(v).to receive(:try).with(:user).and_return(user)
         expect(helper.version_actor_name(v)).to eq("User Name")
       end

       it "returns Unknown when none are present" do
            v = double("Version")
         allow(v).to receive(:respond_to?).and_return(false)
         allow(v).to receive(:try).and_return(nil)
         expect(helper.version_actor_name(v)).to eq("Unknown")
       end
     end

  describe "#version_change_label" do
       it "returns humanized change_type when present" do
            v = double("Version", change_type: :created)
         allow(v).to receive(:respond_to?).with(:change_type).and_return(true)
         expect(helper.version_change_label(v)).to eq("Created")
       end

    it "returns humanized action when present" do
         v = double("Version", action: "deleted")
      allow(v).to receive(:respond_to?).with(:change_type).and_return(false)
      allow(v).to receive(:respond_to?).with(:action).and_return(true)
      expect(helper.version_change_label(v)).to eq("Deleted")
    end

    it "returns Updated when neither change_type nor action present" do
         v = double("Version")
      allow(v).to receive(:respond_to?).and_return(false)
      expect(helper.version_change_label(v)).to eq("Updated")
    end
  end
end
