# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
     # Only allow HTTPS + self
     policy.default_src :self, :https

  # Your external assets
  policy.style_src  :self, :https, :unsafe_inline,
                    "https://cdn.jsdelivr.net",         # Bootstrap CSS
                    "https://fonts.googleapis.com"      # Google Fonts

  policy.script_src :self, :https,
                    "https://cdn.jsdelivr.net"          # Bootstrap JS

  policy.font_src   :self, :https, :data,
                    "https://fonts.gstatic.com"         # Google Fonts files

  policy.img_src    :self, :https, :data
  policy.connect_src :self, :https
  policy.object_src :none
  policy.frame_ancestors :self
end

# If you previously had report-only, disable it in production:
# Rails.application.config.content_security_policy_report_only = false
