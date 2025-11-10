require "rails_helper"

RSpec.describe CmsHelper, type: :helper do
     describe "#cms_html" do
          it "sanitizes and allows safe tags" do
               allow(helper).to receive(:cms_value).and_return("<p><strong>ok</strong><script>alert('x')</script></p>")
            result = helper.cms_html(:hero_title)
            expect(result).to include("<p>")
            expect(result).to include("<strong>ok</strong>")
            expect(result).not_to include("<script")
               # Inner script text may remain per Rails sanitize; ensure no script tag exists
          end

       it "allows safe attributes" do
            allow(helper).to receive(:cms_value).and_return('<a href="http://example.com" target="_blank" rel="noopener">link</a>')
         result = helper.cms_html(:hero_title)
         expect(result).to include('href="http://example.com"')
         expect(result).to include('target="_blank"')
         expect(result).to include('rel="noopener"')
       end
     end

  describe "#cms_text" do
       it "escapes HTML" do
            allow(helper).to receive(:cms_value).and_return("<script>alert('x')</script>")
         result = helper.cms_text(:hero_title)
         expect(result).to eq("&lt;script&gt;alert(&#39;x&#39;)&lt;/script&gt;")
       end

    it "handles nil values" do
         allow(helper).to receive(:cms_value).and_return(nil)
      expect(helper.cms_text(:hero_title)).to eq("")
    end
  end

  describe "#cms_value" do
       it "fetches from HomePageStore" do
            expect(HomePageStore).to receive(:read).and_return({ "hero_title" => "Home" })
         expect(helper.send(:cms_value, :hero_title, page: :home)).to eq("Home")
       end

    it "fetches from RecruitmentPageStore" do
         expect(RecruitmentPageStore).to receive(:read).and_return({ "hero_title" => "Recruitment" })
      expect(helper.send(:cms_value, :hero_title, page: :recruitment)).to eq("Recruitment")
    end

    it "fetches from AboutPageStore" do
         expect(AboutPageStore).to receive(:read).and_return({ "hero_title" => "About" })
      expect(helper.send(:cms_value, :hero_title, page: :about)).to eq("About")
    end

    it "fetches from ContactPageStore" do
         expect(ContactPageStore).to receive(:read).and_return({ "hero_title" => "Contact" })
      expect(helper.send(:cms_value, :hero_title, page: :contact)).to eq("Contact")
    end

    it "returns empty string for unknown page" do
         expect(helper.send(:cms_value, :hero_title, page: :unknown)).to eq("")
    end
  end
end
