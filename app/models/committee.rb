class Committee < ApplicationRecord
  has_many :committee_memberships, dependent: :destroy
  has_many :users, through: :committee_memberships
  has_many :committee_versions, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
