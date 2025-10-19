class Committee < ApplicationRecord
  has_many :committee_memberships, dependent: :destroy
  has_many :users, through: :committee_memberships
  has_many :committee_versions, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  has_one_attached :primary_image
  has_one_attached :secondary_image

  validates :section1_heading, length: { maximum: 120 }
  validates :section2_heading, length: { maximum: 120 }
  validates :description, :section1_body, :section2_body, length: { maximum: 10000 }
end
