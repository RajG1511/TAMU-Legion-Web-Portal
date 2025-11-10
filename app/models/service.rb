class Service < ApplicationRecord
     belongs_to :user
  belongs_to :committee, optional: true

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :name, presence: { message: "Please enter a name" }
  validates :hours,
            presence: { message: "Invalid hours" },
            numericality: { greater_than: 0, less_than_or_equal_to: 100, message: "Invalid hours" }
  validates :date_performed, presence: { message: "Please select a date" }
  validates :description, presence: { message: "Please enter a description" }

  validates :rejection_reason,
            presence: { message: "Please provide a rejection reason" },
            if: -> { rejected? }

  scope :approved, -> { where(status: :approved) }
  scope :pending,  -> { where(status: :pending) }
  scope :recent,   -> { order(date_performed: :desc) }

  after_initialize :set_default_status, if: :new_record?

  private

       def set_default_status
            self.status ||= :pending
       end
end
