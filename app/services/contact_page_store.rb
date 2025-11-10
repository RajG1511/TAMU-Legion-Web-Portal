# app/services/contact_page_store.rb
class ContactPageStore
     PAGE_SLUG = "contact".freeze

  SECTION_KEYS = [
    :hero_title,              # text
    :meetings_title,          # text
    :meetings_body_html,      # html
    :meetings_location,       # text
    :meetings_location_url,   # text
    :meetings_additional_html, # html
    :questions_title,         # text
    :questions_body_html,     # html
    :questions_button_label,  # text
    :questions_button_url,    # text
    :email_list_title,        # text
    :email_list_body_html,    # html
    :email_list_button_label, # text
    :email_list_button_url    # text
  ].freeze

  POSITION_MAP = SECTION_KEYS.each_with_index.to_h { |k, i| [ k, i + 1 ] }.freeze

  DEFAULTS = {
    hero_title: "Contact Us",
    meetings_title: "Want to speak at one of our weekly meetings?",
    meetings_body_html: <<~HTML,
      Our general meetings are held weekly#{' '}
      on <strong>Thursdays at 8:30PM</strong> at#{' '}
      the <strong>Texas A&M Memorial Student Center </strong> unless#{' '}
      specified otherwise. Meeting room details will be given upon#{' '}
      contact.
    HTML
    meetings_location: "275 Joe Routt Blvd, College Station, TX 77843",
    meetings_location_url: "https://aggiemap.tamu.edu/?bldg=0454",
    meetings_additional_html: <<~HTML,
      To join us at a meeting, please email our Vice President#{' '}
      at <a href="mailto:vp.tamulegion@gmail.com">vp.tamulegion@gmail.com</a>.
    HTML
    questions_title: "General Questions",
    questions_body_html: <<~HTML,
      If you have any questions, comments, or concerns, please email#{' '}
      <a href="mailto:president.tamulegion@gmail.com">president.tamulegion@gmail.com</a> or leave it in#{' '}
      the <strong>Dropbox Below</strong>.
    HTML
    questions_button_label: "LEGION Dropbox",
    questions_button_url: "https://docs.google.com/forms/d/e/1FAIpQLSdSuMdPtpXNd7aXZS_NOVHo45HD_L0evBATWI9Fk20bvQTzDA/viewform?usp=sf_link",
    email_list_title: "LEGION Email List",
    email_list_body_html: <<~HTML,
      To receive updates on LEGION's recent activities, sign#{' '}
      up by clicking the link below.
    HTML
    email_list_button_label: "LEGION Email List",
    email_list_button_url: "https://docs.google.com/forms/d/e/1FAIpQLSfyR6I99cuiUL9EbVcDckJMIf0AwzZO6sBKu7fdYqBGteulsQ/viewform?usp=sf_link"
  }

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

  def self.sanitize_html(html)
       raw = html.to_s

     # get rid of any script or style blocks
     raw = raw.gsub(/<script.*?>.*?<\/script>/mi, "")
     raw = raw.gsub(/<style.*?>.*?<\/style>/mi, "")

     # normal html sanitization
     ActionController::Base.helpers.sanitize(
          raw,
          tags: %w[p br strong em b i a ul ol li h1 h2 h3 h4 span],
          attributes: %w[href title target rel class]
     )
  end
end
