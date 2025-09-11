class Student < ApplicationRecord
  # ----- Enums -----
  enum :status, { active: "active", inactive: "inactive" }
  enum :grade, { kindergarten_grade: "K", first_grade: "1", second_grade: "2", third_grade: "3", fourth_grade: "4", fifth_grade: "5", sixth_grade: "6" }

  # ----- Validations -----
  validates :first_name, :last_name, presence: true

  # ----- Associations -----
  has_many :user_students, dependent: :destroy
  has_many :users, through: :user_students

  # ---- Normalizations -----
  # Normalize names before validation
  # None for now

  # ----- Callbacks -----
  # None for now

  # ----- Scopes -----
  # Ordering
  scope :ordered,       -> { order(created_at: :asc) }
  scope :recent_created, -> { order(created_at: :desc) }
  scope :recent_updated, -> { order(updated_at: :desc) }
  scope :by_last_name,  -> { order(last_name: :asc, first_name: :asc) }

  # Status-based
  scope :active,   -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }

  # Grade-based
  scope :kindergarten_grade, -> { where(grade: "K") }
  scope :first_grade,       -> { where(grade: "1") }
  scope :second_grade,      -> { where(grade: "2") }
  scope :third_grade,       -> { where(grade: "3") }
  scope :fourth_grade,     -> { where(grade: "4") }
  scope :fifth_grade,      -> { where(grade: "5") }
  scope :sixth_grade,     -> { where(grade: "6") }

  # Simple free-text search across first_name and last_name
  scope :search, ->(term) do
    next all if term.blank?
    pattern = "%#{term.to_s.downcase.strip}%"
    where("LOWER(first_name) LIKE :term OR LOWER(last_name) LIKE :term", term: pattern)
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
      "This student is inactive. Please contact support."
    else
      super
    end
  end

  private
  # ----- Private Methods -----
  # None for now
end
