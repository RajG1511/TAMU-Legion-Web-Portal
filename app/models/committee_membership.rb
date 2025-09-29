class CommitteeMembership < ApplicationRecord
  belongs_to :user
  belongs_to :committee

  validates :user_id, uniqueness: { scope: :committee_id }
end
