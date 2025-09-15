class Attendance < ApplicationRecord
  # ----- Enums -----
  # None for now - using boolean present field

  # ----- Validations -----
  validates :event, :student, :marked_by, presence: true
  validates :present, inclusion: { in: [ true, false ] }
  validates :student_id, uniqueness: { scope: :event_id, message: "can only have one attendance record per event" }

  # ----- Associations -----
  belongs_to :event
  belongs_to :student
  belongs_to :marked_by, class_name: "User"

  # ----- Normalizations -----
  # None for now

  # ----- Callbacks -----
  before_save :set_marked_at_if_changed
  after_save :send_attendance_notification

  # ----- Scopes -----
  # Ordering
  scope :ordered, -> { joins(:student).order("students.last_name ASC, students.first_name ASC") }
  scope :recent_first, -> { order(marked_at: :desc) }

  # Status-based
  scope :present, -> { where(present: true) }
  scope :absent, -> { where(present: false) }

  # Event-based
  scope :for_event, ->(event) { where(event: event) }

  # Student-based
  scope :for_student, ->(student) { where(student: student) }

  # ----- Instance Methods -----
  def toggle_presence!
    update!(present: !present, marked_at: Time.current)
  end

  def status
    present? ? "present" : "absent"
  end

  def marked_by_name
    marked_by&.full_name || "Unknown"
  end

  # Email notification methods
  def send_attendance_notification
    # Send notification to parents/guardians of this student
    NotificationMailer.send_student_attendance_notification(student, event, self)
  end

  private

  def set_marked_at_if_changed
    self.marked_at = Time.current if present_changed?
  end
end
