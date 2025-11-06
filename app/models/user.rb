class User < ApplicationRecord
  # Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  enum :status, { inactive: 0, active: 1 }
  enum :role,   { nonmember: 0, member: 1, exec: 2, president: 3 }

  # Associations
  has_many :committee_memberships, dependent: :destroy
  has_many :committees, through: :committee_memberships
  has_many :services, dependent: :destroy
  has_many :committee_versions
  has_many :resource_versions
  has_many :event_versions
  has_many :user_versions, dependent: :nullify  # keep logs; block deletes
  has_many_attached :gallery_photos, dependent: :destroy
  has_one_attached :headshot

  after_initialize :apply_defaults, if: :new_record?

  # Force a shared backend password; hide password UI entirely
  before_validation :apply_shared_password, if: :new_record?

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :role,   presence: true
  validates :status, presence: true
  validates :t_shirt_size, inclusion: { in: %w[XS S M L XL XXL XXXL], allow_nil: true }
  validates :graduation_year, numericality: { greater_than: 2020 }, allow_nil: true

  validate :president_role_matches_position

  scope :active,     -> { where(status: :active) }
  scope :members,    -> { where(role: [:member, :exec, :president]) }
  scope :execs,      -> { where(role: [:exec, :president]) }
  scope :leadership, -> { where(role: [:exec, :president]) }

  # Text search that won’t ILIKE integer columns
  def self.search(q)
    return all if q.blank?

    term = "%#{q.strip}%"
    base = where(
      <<~SQL,
        first_name ILIKE :t OR last_name ILIKE :t OR email ILIKE :t OR
        position ILIKE :t OR major ILIKE :t OR CAST(graduation_year AS TEXT) ILIKE :t
      SQL
      t: term
    )

    # Enum matching by name
    role_hits   = roles.keys.select   { |k| k.include?(q.downcase) }
    status_hits = statuses.keys.select{ |k| k.include?(q.downcase) }

    base = base.or(where(role: role_hits))     if role_hits.any?
    base = base.or(where(status: status_hits)) if status_hits.any?
    base
  end

  def full_name = "#{first_name} #{last_name}"
  def president? = role == "president"
  def exec?      = role == "exec" || president?
  def member?    = role == "member" || exec?
  def can_edit_exec_tags? = role == "president"
  def can_manage_members? = exec?
  def can_create_events?  = exec?

  def self.from_google(email:, full_name:, uid:, avatar_url:)
    find_by(email: email) # no auto-create
  end

  private

  def apply_defaults
    self.role   ||= "member"
    self.status ||= "active"
  end

  def apply_shared_password
    shared = ENV["DEFAULT_SHARED_PASSWORD"].presence || SecureRandom.base58(16)
    self.password = self.password_confirmation = shared
  end

  def president_role_matches_position
    if role == "president" && position != "President"
      errors.add(:position, "must be 'President' for president role")
    elsif position == "President" && role != "president"
      errors.add(:role, "must be president for President position")
    end
  end
end

