# app/services/about_page_store.rb
class AboutPageStore
     PAGE_SLUG = "about".freeze

  SECTION_KEYS = [
    :what_is_title,     # text
    :what_is_body_html, # html
    :facts_title,       # text
    :fact_1,            # text
    :fact_2,            # text
    :fact_3,            # text
    :pillars_title,     # text
    :pillar_1,          # text
    :pillar_2,          # text
    :pillar_3           # text
  ].freeze

  POSITION_MAP = SECTION_KEYS.each_with_index.to_h { |k, i| [ k, i + 1 ] }.freeze

  DEFAULTS = {
    what_is_title: "What is LEGION?",
    what_is_body_html: <<~HTML,
    Founded in 2018, LEGION Men's Organization is a student-led#{' '}
    organization at Texas A&M University that aims to develop#{' '}
    its members into leaders by providing a supportive peer group that#{' '}
    encourages personal growth, hosting knowledge workshops and#{' '}
    events to bolster professional goals, participating in community#{' '}
    service, and through the support of our philanthropic partner.
    <br/>#{' '}
    Every week, our members are exposed to opportunities to connect#{' '}
    with their peers, build their educational and professional#{' '}
    knowledge base, meet members of other organizations on campus,#{' '}
    and give back to the community. Our members walk away from LEGION#{' '}
    with greater opportunities and lifelong relationships.
    HTML
    facts_title: "Fast Facts",
    fact_1: "77 Members",
    fact_2: ">1,000 Service Hours",
    fact_3: ">$1,700 Raised",
    pillars_title: "Our Pillars",
    pillar_1: "Brotherhood",
    pillar_2: "Service",
    pillar_3: "Integrity"
  }

  # api for controller
  # TODO: This is not dry at all. These store classes should probably inherit or share a helper or something

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
            p = page || Page.create!(slug: PAGE_SLUG, title: "About")

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
