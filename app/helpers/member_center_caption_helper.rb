# app/helpers/member_center_caption_helper.rb
module MemberCenterCaptionHelper
  # read the saved caption from YAML file
  def member_center_caption_text
    path = Rails.root.join("config", "member_center_caption.yml")
    if File.exist?(path)
      YAML.load_file(path)[:text].html_safe
    else
      "Legion Bingo Card"
    end
  end
end
