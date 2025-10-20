class Page < ApplicationRecord
     has_many :sections, dependent: :destroy
  has_many :page_versions, dependent: :destroy

  validates :slug, presence: true, uniqueness: true

  def latest_sections_with_versions
       sections.includes(:section_versions).order(:position).map do |section|
            [ section, section.section_versions.order(id: :desc).first ]
       end
  end
end
