# app/services/recruitment_page_store.rb
# NOTE: Works without sections.slug — uses page_id + position only.

class RecruitmentPageStore
  PAGE_SLUG = "recruitment".freeze

  # ORDER MATTERS. Position = index + 1
  SECTION_KEYS = %i[
    hero_badge_html          # position 1
    hero_subtitle_html       # position 2
    cta_buttons_html         # position 3
    body_lead_html           # position 4
    contact_html             # position 5
  ].freeze

  def self.read
    ensure_page_and_sections!

    page = Page.find_by!(slug: PAGE_SLUG)
    latest = latest_content_map_for(page)

    SECTION_KEYS.each_with_object({}) do |k, h|
      h[k.to_s] = latest[k.to_s] || ""
    end
  end

  # ----------------------------------------------------------------
  # INTERNALS
  # ----------------------------------------------------------------
  def self.ensure_page_and_sections!
    ActiveRecord::Base.transaction do
      page = Page.find_or_create_by!(slug: PAGE_SLUG) { |p| p.title = "Recruitment" }

      SECTION_KEYS.each_with_index do |key, idx|
        position = idx + 1
        Section.where(page_id: page.id, position: position).first_or_create! do |s|
          # If your schema has :name, this will set it; otherwise it’s ignored.
          s.name = key.to_s.titleize if s.respond_to?(:name)
        end
      end
    end
  end
  private_class_method :ensure_page_and_sections!

  # Build a hash { "hero_badge_html" => "...", ... } with the latest content_html per position.
  def self.latest_content_map_for(page)
    map = {}
    SECTION_KEYS.each_with_index do |key, idx|
      pos = idx + 1

      html = SectionVersion
        .joins(:section)
        .where(sections: { page_id: page.id, position: pos })
        .order(created_at: :desc, id: :desc)
        .limit(1)
        .pick(:content_html)

      map[key.to_s] = html.to_s
    end
    map
  end
  private_class_method :latest_content_map_for
end

