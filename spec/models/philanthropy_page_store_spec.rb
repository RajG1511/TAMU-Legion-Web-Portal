require "rails_helper"

RSpec.describe PhilanthropyPageStore do
  let(:page)    { double("Page", id: 1, slug: "philanthropy", title: "Philanthropy") }
  let(:section) { double("Section", id: 2, position: 1) }
  let(:user)    { double("User", id: 99) }

  # Build a fake relation that responds to order/limit/pick
  def build_section_version_relation(pick_value)
    rel = double("SectionVersion::Relation")
    allow(rel).to receive(:order).and_return(rel)
    allow(rel).to receive(:limit).and_return(rel)
    allow(rel).to receive(:pick).and_return(pick_value)
    rel
  end

  before do
    # clear memoized page between examples
    described_class.instance_variable_set(:@page, nil)

    allow(Page).to receive(:find_by).with(slug: "philanthropy").and_return(page)
    allow(Page).to receive(:create!).and_return(page)

    allow(Section).to receive(:where).and_return(double(pluck: []))
    allow(Section).to receive(:create!).and_return(section)
    allow(Section).to receive(:find_by!).and_return(section)

    stub_const("SectionVersion", double("SectionVersion"))
    allow(SectionVersion).to receive(:create!).and_return(true)

    stub_const("PageVersion", double("PageVersion"))
    allow(PageVersion).to receive(:create!).and_return(double(id: 123))
  end

  describe ".read" do
    it "returns defaults when no content exists" do
      allow(SectionVersion).to receive(:where).and_return(build_section_version_relation(nil))
      result = described_class.read
      expect(result["hero_title"]).to eq("Philanthropy")
      expect(result["partner_link_url"]).to eq("https://www.campsweeney.org")
    end

    it "returns latest content when present" do
      allow(SectionVersion).to receive(:where).and_return(build_section_version_relation("<p>latest</p>"))
      result = described_class.read
      expect(result["hero_title"]).to eq("<p>latest</p>")
    end
  end

  describe ".save_all!" do
    it "creates a PageVersion and SectionVersion records" do
      allow(SectionVersion).to receive(:where).and_return(build_section_version_relation(nil))
      inputs = { hero_title: "<strong>New</strong>" }
      expect(described_class.save_all!(inputs: inputs, user: user)).to eq(true)
      expect(PageVersion).to have_received(:create!)
      expect(SectionVersion).to have_received(:create!)
    end

    it "raises if SectionVersion is not defined" do
      hide_const("SectionVersion")
      inputs = { hero_title: "Test" }
      expect {
        described_class.save_all!(inputs: inputs, user: user)
      }.to raise_error(RuntimeError, /SectionVersion model not found/)
    end
  end

  describe ".page" do
    it "memoizes the page" do
      first = described_class.page
      second = described_class.page
      expect(first).to eq(second)
    end
  end

  describe ".ensure_page_and_sections!" do
    it "creates missing sections" do
      allow(Section).to receive(:where).and_return(double(pluck: [1]))
      expect { described_class.ensure_page_and_sections! }.not_to raise_error
    end
  end

  describe ".section_for" do
    it "finds section by position" do
      expect(described_class.section_for(:hero_title)).to eq(section)
    end
  end

  describe ".latest_content_for" do
    it "returns latest content when SectionVersion defined" do
      allow(SectionVersion).to receive(:where).and_return(build_section_version_relation("<p>latest</p>"))
      expect(described_class.latest_content_for(section)).to eq("<p>latest</p>")
    end

    it "returns nil when SectionVersion not defined" do
      hide_const("SectionVersion")
      expect(described_class.latest_content_for(section)).to be_nil
    end
  end

  describe ".sanitize_html" do
    it "removes script and style tags but keeps safe tags" do
      html = "<script>alert('x')</script><style>body{}</style><p><strong>ok</strong></p>"
      result = described_class.sanitize_html(html)
      expect(result).to include("<p><strong>ok</strong></p>")
      expect(result).not_to include("script")
      expect(result).not_to include("style")
    end
  end
end