class Service < ApplicationRecord
  belongs_to :user

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :hours, presence: true,
                    numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :name, presence: true
  validates :date_performed, presence: true

  scope :approved, -> { where(status: :approved) }
  scope :pending,  -> { where(status: :pending) }
  scope :recent,   -> { order(date_performed: :desc) }

  after_initialize :set_default_status, if: :new_record?

  private

  def set_default_status
    self.status ||= :pending
  end
end
