class Service < ApplicationRecord
  belongs_to :user

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  COMMITTEES = %w[Brotherhood PR Philanthropy Presidential Service Social].freeze

  # Validations with custom messages
  validates :name, presence: { message: "Please enter a name" }

  validates :hours,
            presence: { message: "Invalid hours" },
            numericality: {
              greater_than: 0,
              less_than_or_equal_to: 100,
              message: "Invalid hours"
            }

  validates :date_performed, presence: { message: "Please select a date" }

  validates :committee,
            presence: { message: "Please select a committee" },
            inclusion: { in: COMMITTEES, message: "Please select a valid committee" }

  validates :description, presence: { message: "Please enter a description" }

  # Require rejection_reason only if status is rejected
  validates :rejection_reason,
            presence: { message: "Please provide a rejection reason" },
            if: -> { rejected? }

  # Scopes
  scope :approved, -> { where(status: :approved) }
  scope :pending,  -> { where(status: :pending) }
  scope :recent,   -> { order(date_performed: :desc) }

  # Default status
  after_initialize :set_default_status, if: :new_record?

  private

  def set_default_status
    self.status ||= :pending
  end
end