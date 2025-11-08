# app/models/page_version.rb
class PageVersion < ApplicationRecord
  belongs_to :page
  belongs_to :user
  has_many :section_versions, dependent: :destroy

  enum :change_type, { create: "create", update: "update" }, prefix: :change

  scope :for_page, ->(page) { where(page: page) }
end
