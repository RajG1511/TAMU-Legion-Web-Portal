class UserVersion < ApplicationRecord
  belongs_to :user, optional: true          # actor
  belongs_to :target_user, class_name: "User"

  enum :change_type, { created: 0, updated: 1, deleted: 2, bulk_updated: 3, reset_inactive: 4 }

  validates :change_type, :summary, presence: true
end

