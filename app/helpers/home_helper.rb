# app/helpers/home_helper.rb
module HomeHelper
     # returns raw HTML for *_html sections, plain text otherwise
     def home_section(name)
          @sections[name] || ""
     end
end
