module CmsHelper
  # Render a *sanitized* fragment of HTML from your page store.
  # Use this for fields that are supposed to contain markup (e.g. <p>, <a>, <br>, <strong>).
  def cms_html(key, page: :home)
    raw sanitize(cms_value(key, page: page),
      tags: %w[p br strong em b i u span div a h1 h2 h3 h4 h5 h6 ul ol li small sup sub],
      attributes: %w[href target rel class style])
  end

  # Render a plain text value (escaped). Use for titles, short labels, etc.
  def cms_text(key, page: :home)
    value = cms_value(key, page: page).to_s
    ERB::Util.html_escape(value)
  end

  private

  # Central place to fetch a value from the right store
  def cms_value(key, page:)
    case page.to_sym
    when :home
      # HomePageStore.read returns a Hash-like accessor in your project
      HomePageStore.read.fetch(key.to_s, "")
    when :recruitment
      RecruitmentPageStore.read.fetch(key.to_s, "")
    when :about
      AboutPageStore.read.fetch(key.to_s, "")
    when :contact
      ContactPageStore.read.fetch(key.to_s, "")
    else
      ""
    end
  end
end
