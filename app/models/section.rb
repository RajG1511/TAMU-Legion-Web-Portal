# app/models/section.rb
class Section < ApplicationRecord
     belongs_to :page
  has_many :section_versions, dependent: :destroy

  validates :position, presence: true
end
