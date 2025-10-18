class Resource < ApplicationRecord
  # Associations
  belongs_to :resource_category, optional: true
  has_many   :resource_versions
  has_one_attached :file

  # Callbacks
  before_save :clear_irrelevant_fields

  # Enums
  enum :visibility, { public_resource: 0, members_only: 1, execs_only: 2 }
  enum :published,  { draft: 0, published: 1, unpublished: 2 }

  # Validations
  validates :name, presence: true
  validates :visibility, presence: true
  validates :resource_category_id, presence: true
  validates :resource_type, presence: true, inclusion: { in: %w[file link], message: "must be file or link" }

  # Conditional validations for file resources based on attachment and content type
  with_options if: -> { resource_type == "file" } do
    validates :file, attached: true,
    content_type: ["application/pdf", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/vnd.ms-excel",
                  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.ms-powerpoint",
                  "application/vnd.openxmlformats-officedocument.presentationml.presentation", "image/png", "image/jpeg"]
  end

  # Conditional validations for link resources based on valid URL format
  with_options if: -> { resource_type == "link" } do
    validates :content, presence: true,
    format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  end

  # Returns only published resources
  scope :published, -> { where(published: true) }

  # Determines which resources are visible based on the user's role
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

  private

  # Ensures irrelevant fields are cleared before saving:
    # - If it's a file resource, remove any link content.
    # - If it's a link resource, purge any attached files.
  def clear_irrelevant_fields
    if resource_type == "file"
      self.content = nil if content.present?
    elsif resource_type == "link"
      file.purge if file.attached?
    end
  end
end
