# app/models/section_version.rb
class SectionVersion < ApplicationRecord
  belongs_to :section
  belongs_to :page_version
  belongs_to :user

  enum :change_type, { create: "create", update: "update" }, prefix: :change
end

