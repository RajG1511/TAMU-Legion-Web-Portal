<<<<<<< HEAD
class User < ApplicationRecord

  # Devise
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  # Enums - Updated to include president
  enum :status, { inactive: 0, active: 1 }
  enum :role, { nonmember: 0, member: 1, exec: 2, president: 3 }

  # Associations
  has_many :committee_memberships, dependent: :destroy
  has_many :committees, through: :committee_memberships
  has_many :services, dependent: :destroy
  has_many :committee_versions
  has_many :resource_versions
  has_many :event_versions

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true
  validates :status, presence: true
  validates :t_shirt_size, inclusion: { in: %w[XS S M L XL XXL XXXL], allow_nil: true }
  validates :graduation_year, numericality: { greater_than: 2020 }, allow_nil: true
  
  # Validate that only president role can have President position
  validate :president_role_matches_position

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :members, -> { where(role: [:member, :exec, :president]) }
  scope :execs, -> { where(role: [:exec, :president]) }
  scope :leadership, -> { where(role: [:exec, :president]) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def president?
    role == 'president'
  end

  def exec?
    role == 'exec' || president?
  end

  def member?
    role == 'member' || exec?
  end

  def can_edit_exec_tags?
    role == 'president'
  end

  def can_manage_members?
    exec?
  end

  def can_create_events?
    exec?
  end

  #OAuth mapping
  def self.from_google(email:, full_name:, uid:, avatar_url:)
    # Accounts should not be created automatically by oauth
    user = find_by(email: email)
  end

  private

  def president_role_matches_position
    if role == 'president' && position != 'President'
      errors.add(:position, "must be 'President' for president role")
    elsif position == 'President' && role != 'president'
      errors.add(:role, "must be president for President position")
    end
  end
=======
class User < ApplicationRecord

  # Devise
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable,
       :omniauthable, omniauth_providers: [:google_oauth2]

  # Enums - Updated to include president
  enum :status, { inactive: 0, active: 1 }
  enum :role, { nonmember: 0, member: 1, exec: 2, president: 3 }

  # Associations
  has_many :committee_memberships, dependent: :destroy
  has_many :committees, through: :committee_memberships
  has_many :services, dependent: :destroy
  has_many :committee_versions
  has_many :resource_versions
  has_many :event_versions
  has_many_attached :gallery_photos, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true
  validates :status, presence: true
  validates :t_shirt_size, inclusion: { in: %w[XS S M L XL XXL XXXL], allow_nil: true }
  validates :graduation_year, numericality: { greater_than: 2020 }, allow_nil: true
  
  # Validate that only president role can have President position
  validate :president_role_matches_position

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :members, -> { where(role: [:member, :exec, :president]) }
  scope :execs, -> { where(role: [:exec, :president]) }
  scope :leadership, -> { where(role: [:exec, :president]) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def president?
    role == 'president'
  end

  def exec?
    role == 'exec' || president?
  end

  def member?
    role == 'member' || exec?
  end

  def can_edit_exec_tags?
    role == 'president'
  end

  def can_manage_members?
    exec?
  end

  def can_create_events?
    exec?
  end

  #OAuth mapping
  def self.from_google(email:, full_name:, uid:, avatar_url:)
    # Accounts should not be created automatically by oauth
    user = find_by(email: email)
  end

  private

  def president_role_matches_position
    if role == 'president' && position != 'President'
      errors.add(:position, "must be 'President' for president role")
    elsif position == 'President' && role != 'president'
      errors.add(:role, "must be president for President position")
    end
  end
>>>>>>> origin/test
end