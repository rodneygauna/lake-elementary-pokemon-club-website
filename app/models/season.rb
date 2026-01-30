class Season < ApplicationRecord
  # ----- Enums -----
  enum :status, { active: "active", inactive: "inactive" }

  # ----- Validations -----
  validates :name, presence: true, uniqueness: true
  validates :start_date, :end_date, presence: true
  validate :end_date_after_start_date

  # ----- Associations -----
  has_many :student_seasons, dependent: :destroy
  has_many :students, through: :student_seasons

  # ----- Scopes -----
  # Ordering
  scope :ordered,       -> { order(start_date: :desc) }
  scope :recent_created, -> { order(created_at: :desc) }
  scope :recent_updated, -> { order(updated_at: :desc) }
  scope :chronological, -> { order(start_date: :asc) }

  # Status-based
  scope :active,   -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }

  # Time-based
  scope :current, -> { where("start_date <= ? AND end_date >= ?", Date.current, Date.current).active }
  scope :upcoming, -> { where("start_date > ?", Date.current).active }
  scope :past, -> { where("end_date < ?", Date.current) }

  # ----- Instance Methods -----
  def display_name
    "#{name} (#{start_date.strftime('%b %Y')} - #{end_date.strftime('%b %Y')})"
  end

  def current?
    Date.current.between?(start_date, end_date) && active?
  end

  def upcoming?
    start_date > Date.current && active?
  end

  def past?
    end_date < Date.current
  end

  def student_count
    students.count
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
