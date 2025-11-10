class PhilanthropyPageStore
     PAGE_SLUG = "philanthropy".freeze

  SECTION_KEYS = [
    :hero_title,              # text
    :hero_subtitle,           # text
    :intro_title,             # text
    :intro_body_html,         # html
    :partner_name,            # text
    :partner_title,           # text
    :partner_body_html,       # html
    :partner_link_url,        # text
    :partner_link_label,      # text
    :impact_title,            # text
    :impact_body_html,        # html
    :events_title,            # text
    :events_body_html         # html
  ].freeze

  POSITION_MAP = SECTION_KEYS.each_with_index.to_h { |k, i| [ k, i + 1 ] }.freeze

  DEFAULTS = {
    hero_title: "Philanthropy",
    hero_subtitle: "Our Philanthropy committee maintains our relationship with our partner and organizes events to raise funds.",
    intro_title: "About Camp Sweeney",
    intro_body_html: <<~HTML,
      To a child, a diagnosis of Type 1 Diabetes can be life-altering. To many, their condition can challenge their ability
      to develop feelings of acceptance and self-confidence, further impacting their ability to socialize and find
      fulfillment as they grow and develop.
    HTML
    partner_name: "Camp Sweeney",
    partner_title: "Our Partner",
    partner_body_html: <<~HTML,
      Camp Sweeney aims to provide affected children with a safe space, where world-class medical professionals
      and dedicated staff provide an environment where children no longer need to be concerned with nutrient
      proportions, insulin shots, and the other hurdles that a diagnosis of Type 1 Diabetes brings. This space allows
      campers to build stronger relationships and to find comfort in themselves and their abilities. Sweeney is
      currently the world's largest summer program for Type 1 diabetics, seeing over 30,000 campers annually.
      <br/><br/>
      Since our founding in 2018, LEGION Men's Organization has been a proud partner of Camp Sweeney, raising
      thousands of dollars every semester for Sweeney and its attendees.
    HTML
    partner_link_url: "https://www.campsweeney.org",
    partner_link_label: "Learn More",
    impact_title: "Our Impact",
    impact_body_html: <<~HTML,
      All proceeds of Smoke Out Diabetes go to Camp Sweeney.
    HTML
    events_title: "Smoke Out Diabetes",
    events_body_html: <<~HTML
      Smoke Out Diabetes is our annual fundraising event wherein pitbasters and cooks from across College Station
      and beyond come to compete for prizes provided by sponsors. Guests are encouraged to come to enjoy barbecue,
      live music, and participate in our games and activities. In past years, we partnered with groups including
      C&J Barbecue, Andy's Frozen Custard, Texas Roadhouse, and The Texas A&M Barbecue Club in previous years.
      With strategic house-style Texas Barbecue and to more awareness about Camp Sweeney and Type 1 Diabetes.
    HTML
  }.freeze

  # api for controller
  def self.read
       ensure_page_and_sections!
    SECTION_KEYS.to_h do |key|
         section = section_for(key)
      [ key.to_s, latest_content_for(section) || DEFAULTS[key] ]
    end
  end

  def self.save_all!(inputs:, user:)
       ensure_page_and_sections!
    normalized = inputs.to_h { |k, v| [ k.to_sym, v.to_s ] }

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
           new_html = sanitize_html(new_html)

           s = section_for(key)

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
                raise "SectionVersion model not found. Check autoloading / file name."
           end
         end
    end
    true
  end

  # internals
  def self.page
       @page ||= Page.find_by(slug: PAGE_SLUG)
  end

  def self.ensure_page_and_sections!
       ActiveRecord::Base.transaction do
            p = page || Page.create!(slug: PAGE_SLUG, title: "Philanthropy")

         existing_positions = Section.where(page_id: p.id).pluck(:position)
         needed_positions = POSITION_MAP.values
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
       if defined?(SectionVersion)
            SectionVersion.where(section_id: section.id)
                          .order(created_at: :desc, id: :desc)
                          .limit(1)
                          .pick(:content_html)
       else
            nil
       end
  end

  def self.sanitize_html(html)
       raw = html.to_s
    raw = raw.gsub(/<script.*?>.*?<\/script>/mi, "")
    raw = raw.gsub(/<style.*?>.*?<\/style>/mi, "")
    ActionController::Base.helpers.sanitize(
      raw,
      tags: %w[p br strong em b i a ul ol li h1 h2 h3 h4 span],
      attributes: %w[href title target rel class]
    )
  end
end
