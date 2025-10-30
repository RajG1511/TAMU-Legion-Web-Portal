class Event < ApplicationRecord
     belongs_to :event_category, optional: true
  has_many :event_versions

  # Enums
  enum :visibility, { public_event: 0, members_only: 1, execs_only: 2 }
  enum :published, { draft: 0, published: 1, unpublished: 2 }

  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :event_category_id, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :visibility, presence: true
  validates :published, presence: true
  validates :location_type, presence: true, inclusion: { in: [ "campus", "off_campus", "other_location" ], message: "must be selected" }
  validate :end_time_after_start_time
  validates :campus_number, numericality: { only_integer: true }, allow_nil: true

  # Scopes
  scope :upcoming, -> { where("starts_at > ?", Time.current).order(:starts_at) }
  scope :past, -> { where("ends_at < ?", Time.current).order(starts_at: :desc) }
  scope :published_only, -> { where(published: :published) }
  scope :drafts, -> { where(published: :draft) }

  scope :visible_to, ->(user) {
       base_scope = published_only
    return base_scope.where(visibility: :public_event) if user.nil? || user.nonmember?
    return all if user.exec? || user.president?
    base_scope.where(visibility: [ :public_event, :members_only ])
  }

  # Location Concatenation
  def full_location
       if location_type == "campus" && campus_code.present?
            "#{campus_code} - #{campus_number}"
       elsif location_type == "off_campus" && address.present?
            "#{location_name} - #{address}"
       elsif location_type == "other_location" && location_text.present?
            "#{location_text}"
       end
  end

  # Location validations dependent on selection of location type
  with_options if: -> { location_type == "campus" } do
       validates :campus_code, presence: true
    validates :campus_number, presence: true, numericality: { only_integer: true }
  end
  with_options if: -> { location_type == "off_campus" } do
       validates :location_name, presence: true
    validates :address, presence: true
  end
  with_options if: -> { location_type == "other_location" } do
       validates :location_text, presence: true
  end

  # Callbacks to location fields, reset irrelevant fields during updates
  before_validation :clear_irrelevant_location_fields
  def clear_irrelevant_location_fields
       if on_campus?
            self.location_name = nil
         self.address = nil
         self.location_text = nil
       elsif off_campus?
            self.campus_code = nil
         self.campus_number = nil
         self.location_text = nil
       elsif other_location?
            self.campus_code = nil
         self.campus_number = nil
         self.location_name = nil
         self.address = nil
       end
  end

  # Set full location before saving
  before_save :set_location_from_parts
  def set_location_from_parts
       self.location = full_location
  end

  # Helper methods for location type setting
  def on_campus?
       location_type == "campus"
  end
  def off_campus?
       location_type == "off_campus"
  end
  def other_location?
       location_type == "other_location"
  end

  private

       # date and time helper methods
       def end_time_after_start_time
            return if ends_at.blank? || starts_at.blank?
         errors.add(:ends_at, "must be after start time") if ends_at <= starts_at
       end
end
