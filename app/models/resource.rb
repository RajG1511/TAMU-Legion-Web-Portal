class Resource < ApplicationRecord
  belongs_to :resource_category, optional: true
  has_many :resource_versions, dependent: :destroy

  enum :visibility, { public_resource: 0, members_only: 1, execs_only: 2 }

  validates :name, presence: true
  validates :visibility, presence: true

  scope :visible_to, ->(user) {
    return where(visibility: :public_resource) if user.nil? || user.nonmember?
    return all if user.exec? || user.president?
    where(visibility: [:public_resource, :members_only])
  }
end
