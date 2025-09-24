class Event < ApplicationRecord
  belongs_to :event_category, optional: true
  has_many :event_versions, dependent: :destroy

  enum :visibility, { public_event: 0, members_only: 1, execs_only: 2 }

  validates :name, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :visibility, presence: true
  validate :end_time_after_start_time

  scope :upcoming, -> { where('starts_at > ?', Time.current).order(:starts_at) }
  scope :past, -> { where('ends_at < ?', Time.current).order(starts_at: :desc) }
  scope :visible_to, ->(user) {
    return where(visibility: :public_event) if user.nil? || user.nonmember?
    return all if user.exec? || user.president?
    where(visibility: [:public_event, :members_only])
  }

  private

  def end_time_after_start_time
    return if ends_at.blank? || starts_at.blank?
    errors.add(:ends_at, "must be after start time") if ends_at <= starts_at
  end
end
