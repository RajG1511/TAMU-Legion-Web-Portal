# spec/services/recruitment_page_store_spec.rb
require "rails_helper"

RSpec.describe RecruitmentPageStore, type: :service do
     let(:fake_page) { double(id: 456, slug: "recruitment", title: "Recruitment") }

  before do
       allow(described_class).to receive(:page).and_return(fake_page)
    allow(ActiveRecord::Base).to receive(:transaction).and_yield

    allow(Section).to receive_message_chain(:where, :pluck).and_return([])
    allow(Section).to receive(:create!).and_return(double(id: 20, position: 1))

    allow(SectionVersion).to receive(:create!)
    allow(SectionVersion).to receive_message_chain(:where, :order, :limit, :pick).and_return(nil)

    allow(PageVersion).to receive(:create!).and_return(double(id: 222))
  end

  describe ".read" do
       it "returns defaults when no versions exist" do
            allow(described_class).to receive(:ensure_page_and_sections!).and_return(true)
         allow(described_class).to receive(:section_for).and_return(double(id: 1, position: 1))
         allow(described_class).to receive(:latest_content_for).and_return(nil)

         result = described_class.read
         expect(result.keys).to match_array(described_class::SECTION_KEYS.map(&:to_s))
         expect(result["hero_title"]).to include("Recruitment")
       end

    it "returns latest values when present" do
         allow(described_class).to receive(:ensure_page_and_sections!).and_return(true)
      allow(described_class).to receive(:section_for).and_return(double(id: 1, position: 1))
      # First three keys nil, fourth (apply_url) present
      allow(described_class).to receive(:latest_content_for)
        .and_return(nil, nil, nil, "https://example.com/apply-now")

      result = described_class.read
      expect(result["apply_url"]).to eq("https://example.com/apply-now")
    end
  end

  describe ".save_all!" do
       let(:user) { double(id: 9) }

    before do
         allow(described_class).to receive(:ensure_page_and_sections!).and_return(true)
      RecruitmentPageStore::SECTION_KEYS.each_with_index do |k, idx|
           allow(described_class).to receive(:section_for).with(k)
             .and_return(double(id: 200 + idx, position: idx + 1))
      end
    end

    it "persists SectionVersions for provided inputs and returns true" do
         inputs = {
           hero_title: "Fall 25 Open",
           hero_tagline_html: "<p>Welcome</p>",
           groupme_url: "https://groupme.com/join/abc"
         }
      expect(SectionVersion).to receive(:create!).exactly(inputs.size).times
      ok = described_class.save_all!(inputs: inputs, user: user)
      expect(ok).to be true
    end

    it "creates a PageVersion when defined" do
         expect(PageVersion).to receive(:create!).once.and_return(double(id: 333))
      described_class.save_all!(inputs: { body_html: "<div>x</div>" }, user: user)
    end
  end

  describe ".ensure_page_and_sections!" do
       it "ensures all section positions exist" do
            needed = described_class::POSITION_MAP.values
         expect(Section).to receive(:create!).exactly(needed.size).times
           .with(hash_including(page_id: fake_page.id, position: kind_of(Integer)))
         described_class.ensure_page_and_sections!
       end
  end

  describe ".latest_content_for" do
       it "picks most recent content_html" do
            section = double(id: 77)
         chain = double
         expect(SectionVersion).to receive(:where).with(section_id: 77).and_return(chain)
         expect(chain).to receive(:order).with(created_at: :desc, id: :desc).and_return(chain)
         expect(chain).to receive(:limit).with(1).and_return(chain)
         expect(chain).to receive(:pick).with(:content_html).and_return("X")
         expect(described_class.latest_content_for(section)).to eq("X")
       end
  end
end
