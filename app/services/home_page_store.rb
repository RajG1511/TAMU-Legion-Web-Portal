# app/services/home_page_store.rb
class HomePageStore
  SLUG = "home".freeze
  SECTION_KEYS = %w[hero about recruitment committees faq contact].freeze

  DEFAULTS = {
    "hero" => <<~HTML,
      <h1>Texas A&M Legion</h1>
      <p>Lead. Serve. Build community.</p>
      <p><a class="btn btn-gold" href="#">Apply Now</a> <a class="white-btn" href="#learn-more">Learn More</a></p>
    HTML
    "about"        => "<p>Legion is a student org focused on leadership, service, and professional growth.</p>",
    "recruitment"  => "<pre>- Info Session: TBD\n- Applications Close: TBD</pre>",
    "committees"   => "<p>- Events<br>- Resources<br>- Services</p>",
    "faq"          => "<pre>Q: Who can apply?\nA: All TAMU students are welcome.</pre>",
    "contact"      => '<p>Questions? <a href="mailto:legion@example.edu">legion@example.edu</a></p>'
  }.freeze

  def self.ensure_page!
    page = Page.find_or_create_by!(slug: SLUG) { |p| p.title = "Legion" }
    SECTION_KEYS.each_with_index { |_k, i| Section.find_or_create_by!(page_id: page.id, position: i + 1) }
    page
  end

  # Returns [{key:, section:, version_html:}, ...]
  def self.read
    page = ensure_page!
    page.sections.order(:position).map.with_index do |section, idx|
      latest = section.section_versions.order(id: :desc).first
      {
        key: SECTION_KEYS[idx],
        section: section,
        version_html: (latest&.content_html.presence || DEFAULTS[SECTION_KEYS[idx]])
      }
    end
  end

  # Writes one page_version + N section_versions (no schema change)
  def self.save_all!(inputs:, user:)
    page = ensure_page!
    pv = PageVersion.create!(
      page: page, user: user, slug: page.slug, title: page.title, change_type: "update"
    )
    page.sections.order(:position).each_with_index do |section, idx|
      key = SECTION_KEYS[idx]
      SectionVersion.create!(
        section: section, page_version: pv, user: user,
        position: section.position, content_html: inputs[key].to_s, change_type: "update"
      )
    end
    pv
  end
end

