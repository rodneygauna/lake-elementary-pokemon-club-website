class User < ApplicationRecord
  # ----- Enums -----
  enum :role, { user: "user", admin: "admin" }
  enum :status, { active: "active", inactive: "inactive", suspended: "suspended" }

  # ----- Validations -----
  validates :email_address, :first_name, :last_name, :role, :status, presence: true
  validates :email_address, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, format: { with: /\A\+?[0-9\s\-\(\)]*\z/ }, allow_blank: true

  # ----- Associations -----
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :user_students, dependent: :destroy
  has_many :students, through: :user_students
  has_many :marked_attendances, class_name: "Attendance", foreign_key: "marked_by_id", dependent: :destroy

  # ---- Normalizations -----
  # Normalize email before validation
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # ----- Callbacks -----
  # None for now

  # ----- Scopes -----
  # Ordering
  scope :ordered,      -> { order(created_at: :asc) }
  scope :recent_created, -> { order(created_at: :desc) }
  scope :recent_updated, -> { order(updated_at: :desc) }
  scope :by_last_name, -> { order(last_name: :asc, first_name: :asc) }

  # Role-based
  scope :admins, -> { where(role: "admin") }
  scope :users,  -> { where(role: "user") }

  # Status-based
  scope :active,    -> { where(status: "active") }
  scope :inactive,  -> { where(status: "inactive") }
  scope :suspended, -> { where(status: "suspended") }

  # Simiple free-text search across first_name, last_name, and email_address
  scope :search, ->(term) do
    next all if term.blank?
    pattern = "%#{term.to_s.downcase.strip}%"
    where("LOWER(first_name) LIKE :term OR LOWER(last_name) LIKE :term OR LOWER(email_address) LIKE :term", term: pattern)
  end

  # ----- Instance Methods -----
  def full_name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name.first}#{last_name.first}".upcase
  end

  def active_for_authentication?
    super && status == "active"
  end

  def inactive_message
    if status == "inactive"
      "Your account is inactive. Please contact support."
    elsif status == "suspended"
      "Your account has been suspended. Please contact support."
    else
      super
    end
  end

  private
  # ----- Private Methods -----
  # None for now
end
