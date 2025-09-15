class UserStudent < ApplicationRecord
  # ----- Associations -----
  belongs_to :user
  belongs_to :student

  # ----- Validations -----
  validates :user_id, presence: true
  validates :student_id, presence: true
  # Ensure a user cannot be linked to the same student multiple times
  validates :student_id, uniqueness: { scope: :user_id }

  # ----- Callbacks -----
  after_create :send_student_linked_notification
  after_destroy :send_student_unlinked_notification

  # ----- Scopes -----
  scope :by_user,    ->(user_id) { where(user_id: user_id) }
  scope :by_student, ->(student_id) { where(student_id: student_id) }

  # ----- Instance Methods -----
  def user_to_student_link
    "UserStudent: User##{user_id} <-> Student##{student_id}"
  end

  # Email notification methods
  def send_student_linked_notification
    NotificationJob.perform_later("student_linked", user_id, student_id)
  end

  def send_student_unlinked_notification
    NotificationJob.perform_later("student_unlinked", user_id, student_id)
  end

  private
  # ----- Private Methods -----
  # None for now
end
