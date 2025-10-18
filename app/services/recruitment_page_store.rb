# frozen_string_literal: true

class RecruitmentPageStore
  PAGE_SLUG = "recruitment".freeze

  # Adjust this list to the sections you want to manage on the Recruitment page
  SECTION_KEYS = %i[
    banner_title_html
    banner_cta_primary_text
    banner_cta_primary_url
    banner_cta_secondary_text
    banner_cta_secondary_url
    lead_title
    lead_body_html
    schedule_image_url
    contact_email
  ].freeze

  # ---------- READ ----------
  def self.read
    ensure_page_and_sections!(PAGE_SLUG)

    page = Page.find_by!(slug: PAGE_SLUG)

    # Build a hash of latest content for each section *by slug*
    latest = {}

    SECTION_KEYS.each do |slug|
      section = page.sections.find_by(slug: slug)
      latest[slug.to_s] =
        if section
          SectionVersion
            .where(section_id: section.id)
            .order(created_at: :desc, id: :desc)
            .limit(1)
            .pick(:content_html)
            .to_s
        else
          "" # shouldn’t happen because we ensure sections, but safe
        end
    end

    latest
  end

  # ---------- SAVE (execs) ----------
  # Mirror the pattern your HomePageStore uses; swap in your own versioning method if different.
  def self.save_all!(inputs:, user:)
    ensure_page_and_sections!(PAGE_SLUG)
    Section.version_all!(page_slug: PAGE_SLUG, inputs: inputs, author: user)
  end

  # ---------- INTERNAL ----------
  # IMPORTANT: accept the page slug (fixes “wrong number of arguments” you saw earlier)
  def self.ensure_page_and_sections!(slug)
    ActiveRecord::Base.transaction do
      page = Page.find_or_create_by!(slug: slug) { |p| p.title = slug.titleize }

      SECTION_KEYS.each_with_index do |section_slug, i|
        s = page.sections.find_or_initialize_by(slug: section_slug)
        s.position ||= i + 1
        s.name     ||= section_slug.to_s.titleize
        s.save! if s.changed?
      end
    end
  end
end

