require "rails_helper"

RSpec.describe "home/index.html.erb", type: :view do
     let(:sections) do
          {
            "hero_badge_html"            => "<strong>We are LEGION!</strong><br/><small>Howdy</small>",
            "who_we_are_title"           => "Who we are",
            "who_we_are_body_html"       => "<p>Hello <strong>world</strong></p>",
            "partner_title"              => "Our Partner",
            "partner_body_html"          => "<p>Partner body</p>",
            "footer_diversity_title"     => "Diversity Statement",
            "footer_diversity_body_html" => "<p>Diversity body</p>"
          }
     end

  before do
       # Stub the store to return our test content
       allow(HomePageStore).to receive(:read).and_return(sections)
    # Assign @sections so the view can use it
    assign(:sections, sections)

    # Avoid route dependencies the template links to
    allow(view).to receive(:resources_path).and_return("/resources")

    # Default: no signed-in user (so no edit button)
    allow(view).to receive(:current_user).and_return(nil)
  end

  it "renders the who-we-are title and sanitized body" do
       render template: "home/index"

    expect(rendered).to include("Who we are")
    # cms_html returns sanitized+raw; allowed tags like <strong> should survive
    expect(rendered).to include("<strong>world</strong>")
  end

  context "when user is an exec" do
       it "shows the Edit Home Page button" do
            exec_user = double(exec?: true, president?: false)
         allow(view).to receive(:current_user).and_return(exec_user)

         render template: "home/index"

         expect(rendered).to include("Edit Home Page")
         expect(rendered).to include(edit_home_path)
       end
  end

  context "when user is not exec/president" do
       it "does not show the Edit Home Page button" do
            render template: "home/index"
         expect(rendered).not_to include("Edit Home Page")
       end
  end
end
