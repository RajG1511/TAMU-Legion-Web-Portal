# app/services/home_page_store.rb
class HomePageStore
  PAGE_SLUG = "home".freeze

  # The edit form / controller already expects these keys
  SECTION_KEYS = [
    :hero_badge_html,          # html
    :who_we_are_title,         # text
    :who_we_are_body_html,     # html
    :partner_title,            # text
    :partner_body_html,        # html
    :footer_diversity_title,   # text
    :footer_diversity_body_html # html
  ].freeze

  # Map logical keys to physical section positions (1..N)
  POSITION_MAP = SECTION_KEYS.each_with_index.to_h { |k, i| [k, i + 1] }.freeze

  DEFAULTS = {
    hero_badge_html: <<~HTML.strip,
      <strong>We are LEGION!</strong><br/>
      <small>A Men’s Organization at Texas A&M University</small>
    HTML
    who_we_are_title:       "Who we are",
    who_we_are_body_html:   <<~HTML,
      LEGION is a Men’s Organization that aims to build future leaders at Texas A&M through
      <strong>brotherhood, service</strong>, and <strong>integrity</strong>. The men of Legion share common goals
      of self-improvement through giving back to the community of the Brazos Valley, learning to build meaningful
      relationships, and holding themselves to a higher standard.
    HTML
    partner_title:          "Our Partner",
    partner_body_html:      <<~HTML,
      All proceeds of LEGION's philanthropic events go to Camp Sweeney, a summer camp benefitting children
      suffering from Type 1 diabetes. LEGION is proud to have been a partner of the Camp since the
      organization’s founding in 2018.
    HTML
    footer_diversity_title: "Diversity Statement",
    footer_diversity_body_html: <<~HTML,
      LEGION is committed to establishing a diverse environment and does not discriminate on the basis of race,
      religion, color, sexual orientation, disability, or country of origin. Members who do not abide by these
      rules will have their membership canceled.
    HTML
  }.freeze

  # ---------- Public API used by HomeController ----------

  # Returns a hash { "hero_badge_html" => "...", ... }
  def self.read
    ensure_page_and_sections!
    SECTION_KEYS.to_h do |key|
      section = section_for(key)
      [key.to_s, latest_content_for(section) || DEFAULTS[key]]
    end
  end

  # inputs: { key_sym/string => html/text }
  def self.save_all!(inputs:, user:)
    ensure_page_and_sections!
    normalized = inputs.to_h { |k, v| [k.to_sym, v.to_s] }

    # Optional: record a page_version entry when saving
    pv_id = nil
    if defined?(PageVersion)
      pv = PageVersion.create!(
        page_id: page.id,
        user_id: user&.id,
        slug: page.slug,
        title: page.title,
        change_type: "update"
      )
      pv_id = pv.id
    end

    Section.transaction do
      SECTION_KEYS.each do |key|
        new_html = normalized[key]
        next if new_html.nil?

        s = section_for(key)

        # Write a new SectionVersion row (your schema stores content here)
        attrs = {
          section_id: s.id,
          page_version_id: pv_id,
          user_id: user&.id,
          position: s.position,
          content_html: new_html,
          change_type: "update"
        }.compact

        if defined?(SectionVersion)
          SectionVersion.create!(attrs)
        else
          # If for some reason SectionVersion is not loaded, raise explicitly
          raise "SectionVersion model not found. Check autoloading / file name."
        end
      end
    end
    true
  end

  # ---------- Internals ----------

  def self.page
    @page ||= Page.find_by(slug: PAGE_SLUG)
  end

  def self.ensure_page_and_sections!
    ActiveRecord::Base.transaction do
      p = page || Page.create!(slug: PAGE_SLUG, title: "Home")

      # Ensure we have N sections with positions 1..N for this page
      existing_positions = Section.where(page_id: p.id).pluck(:position)
      needed_positions   = POSITION_MAP.values
      (needed_positions - existing_positions).sort.each do |pos|
        Section.create!(page_id: p.id, position: pos)
      end
    end
  end

  def self.section_for(key)
    pos = POSITION_MAP.fetch(key)
    Section.find_by!(page_id: page.id, position: pos)
  end

  def self.latest_content_for(section)
    # Grab latest by created_at (fallback id) for this section
    if defined?(SectionVersion)
      SectionVersion.where(section_id: section.id)
                    .order(created_at: :desc, id: :desc)
                    .limit(1)
                    .pick(:content_html)
    else
      nil
    end
  end
end

