require "rails_helper"

RSpec.describe HomeHelper, type: :helper do
     describe "#home_section" do
          it "returns value when present in @sections" do
               helper.instance_variable_set(:@sections, { "who_we_are_title" => "Who we are" })

            expect(helper.home_section("who_we_are_title")).to eq("Who we are")
          end

       it "returns empty string when key is missing" do
            helper.instance_variable_set(:@sections, { "hero_badge_html" => "<b>Badge</b>" })

         expect(helper.home_section("who_we_are_title")).to eq("")
       end
     end
end
