# spec/services/home_page_store_spec.rb
require "rails_helper"

RSpec.describe HomePageStore, type: :service do
     let(:fake_page) { double(id: 123, slug: "home", title: "Home") }

  before do
       # Do not touch the real DB
       allow(described_class).to receive(:page).and_return(fake_page)
    allow(ActiveRecord::Base).to receive(:transaction).and_yield

    # Section stubs used by ensure_page_and_sections!
    allow(Section).to receive_message_chain(:where, :pluck).and_return([]) # no existing sections
    allow(Section).to receive(:create!).and_return(double(id: 10, position: 1))

    # Version model stubs
    allow(SectionVersion).to receive(:create!)
    allow(SectionVersion).to receive_message_chain(:where, :order, :limit, :pick).and_return(nil)

    allow(PageVersion).to receive(:create!).and_return(double(id: 999))
  end

  describe ".read" do
       it "returns defaults when latest content is nil" do
            allow(described_class).to receive(:ensure_page_and_sections!).and_return(true)
         allow(described_class).to receive(:section_for).and_return(double(id: 1, position: 1))
         allow(described_class).to receive(:latest_content_for).and_return(nil)

         result = described_class.read
         expect(result.keys).to match_array(HomePageStore::SECTION_KEYS.map(&:to_s))
         expect(result["who_we_are_title"]).to eq(HomePageStore::DEFAULTS[:who_we_are_title])
       end

    it "uses latest content when present" do
         allow(described_class).to receive(:ensure_page_and_sections!).and_return(true)
      allow(described_class).to receive(:section_for).and_return(double(id: 1, position: 1))

      call_order = 0
      allow(described_class).to receive(:latest_content_for) do
           call_order += 1
        # In HomePageStore::SECTION_KEYS, :who_we_are_title is 2nd
        call_order == 2 ? "Custom Who" : nil
      end

      result = described_class.read
      expect(result["who_we_are_title"]).to eq("Custom Who")
    end
  end

  describe ".save_all!" do
       let(:user) { double(id: 7) }

    before do
         allow(described_class).to receive(:ensure_page_and_sections!).and_return(true)
      HomePageStore::SECTION_KEYS.each_with_index do |k, idx|
           allow(described_class).to receive(:section_for).with(k)
             .and_return(double(id: 100 + idx, position: idx + 1))
      end
    end

    it "creates a SectionVersion row per provided input and returns true" do
         inputs = {
           hero_badge_html: "<b>Badge</b>",
           who_we_are_title: "Title",
           who_we_are_body_html: "<p>Body</p>"
         }
      expect(SectionVersion).to receive(:create!).exactly(inputs.size).times
      ok = described_class.save_all!(inputs: inputs, user: user)
      expect(ok).to be true
    end

    it "creates a PageVersion when the model is defined" do
         expect(PageVersion).to receive(:create!).once.and_return(double(id: 111))
      described_class.save_all!(inputs: { partner_title: "PT" }, user: user)
    end
  end

  describe ".ensure_page_and_sections!" do
       it "creates missing Section rows for all defined positions" do
            needed_positions = HomePageStore::POSITION_MAP.values
         expect(Section).to receive(:create!).exactly(needed_positions.size).times
           .with(hash_including(page_id: fake_page.id, position: kind_of(Integer)))
         described_class.ensure_page_and_sections!
       end
  end

  describe ".latest_content_for" do
       it "picks most recent SectionVersion content_html when SectionVersion is defined" do
            section = double(id: 33)
         chain = double
         expect(SectionVersion).to receive(:where).with(section_id: 33).and_return(chain)
         expect(chain).to receive(:order).with(created_at: :desc, id: :desc).and_return(chain)
         expect(chain).to receive(:limit).with(1).and_return(chain)
         expect(chain).to receive(:pick).with(:content_html).and_return("HTML")

         expect(described_class.latest_content_for(section)).to eq("HTML")
       end
  end
end
