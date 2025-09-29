class Resource < ApplicationRecord
  belongs_to :resource_category, optional: true
  has_many :resource_versions
  has_one_attached :file

  enum :visibility, { public_resource: 0, members_only: 1, execs_only: 2 }

  validates :name, presence: true
  validates :visibility, presence: true
  validates :resource_category_id, presence: true
  validates :file, attached: true, content_type: [
    "application/pdf",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/vnd.ms-excel",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "application/vnd.ms-powerpoint",
    "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "image/png",
    "image/jpeg"
  ]

  scope :published, -> { where(published: true) }

  # Returns a relation of resources visible to the given user
  def self.visible_to(user)
    return where(visibility: :public_resource) if user.nil? || user.try(:nonmember?)

    if user.president? || user.exec?
      where(visibility: [:public_resource, :members_only, :execs_only])
    elsif user.member?
      where(visibility: [:public_resource, :members_only])
    else
      where(visibility: :public_resource)
    end
  end
end
