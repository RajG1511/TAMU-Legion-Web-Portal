class EventVersion < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :name, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true
end
