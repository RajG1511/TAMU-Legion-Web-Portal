class Event < ApplicationRecord
  belongs_to :event_category, optional: true
  has_many :event_versions, dependent: :destroy

  # Enums
  enum :visibility, { public_event: 0, members_only: 1, execs_only: 2 }
  enum :published, { draft: 0, published: 1 }

  # Validations
  validates :name, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :visibility, presence: true
  validates :published, presence: true
  validate :end_time_after_start_time
  validates :campus_number, numericality: { only_integer: true }, allow_nil: true

  # Scopes
  scope :upcoming, -> { where('starts_at > ?', Time.current).order(:starts_at) }
  scope :past, -> { where('ends_at < ?', Time.current).order(starts_at: :desc) }
  scope :published_only, -> { where(published: :published) }
  scope :drafts, -> { where(published: :draft) }
  
  scope :visible_to, ->(user) {
    base_scope = published_only
    return base_scope.where(visibility: :public_event) if user.nil? || user.nonmember?
    return all if user.exec? || user.president?
    base_scope.where(visibility: [:public_event, :members_only])
  }

  # Location helper methods
  def full_location
    if location_type == 'campus' && campus_code.present?
      "#{campus_code}#{campus_number} - #{location_name}"
    elsif address.present?
      address
    else
      location_name || location
    end
  end

  def on_campus?
    location_type == 'campus'
  end

  private

  def end_time_after_start_time
    return if ends_at.blank? || starts_at.blank?
    errors.add(:ends_at, "must be after start time") if ends_at <= starts_at
  end
end
