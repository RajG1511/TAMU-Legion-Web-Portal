# app/services/recruitment_page_store.rb
class RecruitmentPageStore
  PAGE_SLUG = "recruitment".freeze

  # order matters (for stable insert)
  SECTION_KEYS = %i[
    hero_title
    hero_tagline_html
    body_html
    apply_url
    groupme_url
    contact_email
  ].freeze

  DEFAULTS = {
    hero_title:          "Recruitment for Fall 2025 is open!",
    hero_tagline_html:   "Apply below to be considered for acceptance.<br>Follow us on our social channels for updates on the recruitment cycle.",
    body_html:           "", # leave empty (the Wix page doesn’t need extra body)
    apply_url:           "https://forms.gle/your-form-here",
    groupme_url:         "https://groupme.com/join_group/your-groupme-id",
    contact_email:       "proflicter.tamulegion@gmail.com"
  }.stringify_keys.freeze

  # Public API ---------------------------------------------------------------

  def self.read
    ensure_page_and_sections!
    latest = latest_content_for(PAGE_SLUG)
    SECTION_KEYS.each_with_object({}) do |k, h|
      h[k.to_s] = latest[k.to_s].presence || DEFAULTS[k.to_s]
    end
  end

  def self.save_all!(inputs:, user:)
    ensure_page_and_sections!
    page = Page.find_by!(slug: PAGE_SLUG)

    inputs.slice(*SECTION_KEYS.map(&:to_s)).each do |slug, content|
      section = page.sections.find_by!(slug: slug)
      SectionVersion.create!(
        section: section,
        user_id: user&.id,
        content_html: (content || "").to_s.strip
      )
    end
  end

  # Helpers (mirror the style of your HomePageStore) ------------------------

  def self.ensure_page_and_sections!
  ActiveRecord::Base.transaction do
    page = Page.find_or_create_by!(slug: PAGE_SLUG) { |p| p.title = "Recruitment" }

    # Serialize section creation for this page to avoid unique(position) races
    page.with_lock do
      SECTION_KEYS.each do |slug|
        # If it already exists by slug, we're done
        next if page.sections.find_by(slug: slug)

        # Compute next open position *after* acquiring the lock
        next_pos = next_open_position_for(page.reload)

        page.sections.create!(
          slug:     slug,                 # keep your slug approach
          name:     slug.to_s.titleize,
          position: next_pos
        )
      end
    end
  end
rescue ActiveRecord::RecordNotUnique
  # In case two threads collided right around the lock boundary, reload and try once more
  retry
end


  # Returns the first free integer position for this page
  def self.next_open_position_for(page)
    used = page.sections.pluck(:position).compact
    pos  = 1
    while used.include?(pos)
      pos += 1
    end
    pos
  end


  def self.latest_content_for(page_slug)
    page = Page.find_by!(slug: page_slug)
    sections = page.sections.order(:position)

    sections.each_with_object({}) do |section, h|
      content = SectionVersion.where(section_id: section.id)
                              .order(created_at: :desc, id: :desc)
                              .limit(1)
                              .pick(:content_html)
      h[section.slug] = content.to_s
    end
  end
end
