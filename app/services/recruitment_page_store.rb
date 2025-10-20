# app/services/recruitment_page_store.rb
class RecruitmentPageStore
     PAGE_SLUG = "recruitment".freeze

  # Keys the controller/views expect
  SECTION_KEYS = [
    :hero_title,         # text
    :hero_tagline_html,  # html
    :body_html,          # html (optional block below flyer)
    :apply_url,          # text (URL)
    :groupme_url,        # text (URL)
    :contact_email       # text (email)
  ].freeze

  # Map logical keys to physical section positions (1..N), exactly like HomePageStore
  POSITION_MAP = SECTION_KEYS.each_with_index.to_h { |k, i| [ k, i + 1 ] }.freeze

  DEFAULTS = {
    hero_title:          "Recruitment for Fall 2025 is open!",
    hero_tagline_html:   "Apply below to be considered for acceptance.<br>Follow us on our social channels for updates on the recruitment cycle.",
    body_html:           "",
    apply_url:           "https://forms.gle/your-form-here",
    groupme_url:         "https://groupme.com/join_group/your-groupme-id",
    contact_email:       "proflicter.tamulegion@gmail.com"
  }.freeze

  # ---------- Public API used by RecruitmentController ----------

  # Returns a hash { "hero_title" => "...", ... }
  def self.read
       ensure_page_and_sections!
    SECTION_KEYS.to_h do |key|
         s = section_for(key)
      [ key.to_s, latest_content_for(s) || DEFAULTS[key] ]
    end
  end

  # inputs: { key_sym/string => html/text }
  def self.save_all!(inputs:, user:)
       ensure_page_and_sections!
    normalized = inputs.to_h { |k, v| [ k.to_sym, v.to_s ] }

    # Optional page version, matching style in HomePageStore
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
              new_value = normalized[key]
           next if new_value.nil?

           s = section_for(key)
           attrs = {
             section_id:     s.id,
             page_version_id: pv_id,
             user_id:        user&.id,
             position:       s.position,
             content_html:   new_value,
             change_type:    "update"
           }.compact

           raise "SectionVersion model not found" unless defined?(SectionVersion)
           SectionVersion.create!(attrs)
         end
    end
    true
  end

  # ---------- Internals (mirrors HomePageStore) ----------

  def self.page
       @page ||= Page.find_by(slug: PAGE_SLUG)
  end

  def self.ensure_page_and_sections!
       ActiveRecord::Base.transaction do
            p = page || Page.create!(slug: PAGE_SLUG, title: "Recruitment")

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
       return nil unless defined?(SectionVersion)
    SectionVersion.where(section_id: section.id)
                  .order(created_at: :desc, id: :desc)
                  .limit(1)
                  .pick(:content_html)
  end
end
