require "rails_helper"

RSpec.describe ContactPageStore do
  let(:executive) { create(:user, role: :exec) }

  it "strips disallowed html from sections" do
    inputs = { 
      "questions_body_html" => "Hello <script>alert(1)</script> <strong>world</strong>",
    }

    expect {
      ContactPageStore.save_all!(inputs: inputs, user: executive)
    }.to change(SectionVersion, :count).by(1)

    section_version = SectionVersion.order(created_at: :desc).first
    expect(section_version.content_html).to eq("Hello  <strong>world</strong>")
  end
end