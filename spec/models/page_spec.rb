require 'rails_helper'

RSpec.describe Page, type: :model do
  describe "validations" do
    it "requires a slug" do
      page = Page.new
      expect(page.valid?).to be false
      expect(page.errors[:slug]).to include("can't be blank")
    end

    it "requires slug to be unique" do
      Page.create!(slug: "about", title: "About")
      dup = Page.new(slug: "about", title: "Duplicate")
      expect(dup.valid?).to be false
      expect(dup.errors[:slug]).to include("has already been taken")
    end
  end

  describe "#latest_sections_with_versions" do
    it "returns sections with nil versions when none exist" do
      page = Page.create!(slug: "about", title: "About")
      section = Section.create!(page: page, position: 1)
      result = page.latest_sections_with_versions
      expect(result).to eq([[section, nil]])
    end

    it "returns the latest version for each section" do
      # Create a valid user with all required fields
      user = User.create!(
        email: "test@example.com",
        password: "password123",
        first_name: "Test",
        last_name: "User"
      )

      page = Page.create!(slug: "about", title: "About")
      section = Section.create!(page: page, position: 1)

      pv = PageVersion.create!(
        page: page,
        user: user,
        slug: page.slug,
        title: page.title,
        change_type: "update"
      )

      old_version = SectionVersion.create!(
        section: section,
        page_version: pv,
        user: user,
        position: 1,
        content_html: "Old",
        change_type: "update"
      )

      new_version = SectionVersion.create!(
        section: section,
        page_version: pv,
        user: user,
        position: 1,
        content_html: "New",
        change_type: "update"
      )

      result = page.latest_sections_with_versions
      expect(result).to eq([[section, new_version]])
    end
  end
end