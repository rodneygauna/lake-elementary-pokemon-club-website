class Student < ApplicationRecord
  # ----- Enums -----
  enum :status, { active: "active", inactive: "inactive" }
  enum :grade, { kindergarten_grade: "K", first_grade: "1", second_grade: "2", third_grade: "3", fourth_grade: "4", fifth_grade: "5", sixth_grade: "6" }

  # ----- Validations -----
  validates :first_name, :last_name, presence: true

  # ----- Associations -----
  has_many :user_students, dependent: :destroy
  has_many :users, through: :user_students
  has_many :attendances, dependent: :destroy
  has_many :attended_events, -> { where(attendances: { present: true }) }, through: :attendances, source: :event
  has_many :student_seasons, dependent: :destroy
  has_many :seasons, through: :student_seasons

  # ---- Normalizations -----
  # Normalize names before validation
  # None for now

  # ----- Callbacks -----
  after_update :send_profile_update_notifications

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
    status == "active"
  end

  def inactive_message
    if status == "inactive"
      "This student is inactive. Please contact support."
    else
      super
    end
  end

  def display_name_for(user)
    # Admin and super_user can see all full names
    return full_name if user&.admin_level?

    # Linked parents can see their student's full name
    return full_name if user && users.include?(user)

    # Everyone else sees initials
    initials
  end

  def grade_display
    # Convert grade enum to readable format
    # Handle both old enum keys (like "third_grade") and new enum values (like "3")
    grade_value = read_attribute(:grade)

    case grade_value
    when "K", "kindergarten_grade" then "Kindergarten"
    when "1", "first_grade" then "1st Grade"
    when "2", "second_grade" then "2nd Grade"
    when "3", "third_grade" then "3rd Grade"
    when "4", "fourth_grade" then "4th Grade"
    when "5", "fifth_grade" then "5th Grade"
    when "6", "sixth_grade" then "6th Grade"
    else grade_value.to_s.titleize
    end
  end

  def pokemon_experience
    # Return default experience level for templates
    # This field doesn't exist in the current schema, so return a placeholder
    "Beginner"
  end

  # Email notification methods
  def send_profile_update_notifications
    # Only send notifications if significant fields changed
    return unless saved_changes.any?

    significant_changes = saved_changes.keys & %w[first_name last_name grade favorite_pokemon pokemon_experience]

    if significant_changes.any?
      NotificationJob.perform_later("student_profile_updated", id, significant_changes)
    end
  end

  private
  # ----- Private Methods -----
  # None for now
end
