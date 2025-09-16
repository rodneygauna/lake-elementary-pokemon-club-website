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
  before_destroy :send_student_unlinked_notification

  # ----- Scopes -----
  scope :by_user,    ->(user_id) { where(user_id: user_id) }
  scope :by_student, ->(student_id) { where(student_id: student_id) }

  # ----- Instance Methods -----
  def user_to_student_link
    "UserStudent: User##{user_id} <-> Student##{student_id}"
  end

  # Email notification methods
  def send_student_linked_notification
    # Notify the newly linked user (background job is fine for this)
    NotificationJob.perform_later("student_linked", user_id, student_id)

    # Notify existing parents about the new parent being linked (synchronous for reliability)
    # This ensures all existing parents get notified immediately
    begin
      NotificationMailer.send_new_parent_linked_notifications(student, user)
    rescue => e
      Rails.logger.error "Failed to send new parent linked notifications: #{e.message}"
      # Fallback to background job if synchronous delivery fails
      NotificationJob.perform_later("new_parent_linked", student_id, user_id)
    end
  end

  def send_student_unlinked_notification
    # Notify the unlinked user (synchronous for reliability)
    begin
      NotificationMailer.send_student_unlinked_notification(user, student)
    rescue => e
      Rails.logger.error "Failed to send student unlinked notification: #{e.message}"
      # Fallback to background job if synchronous delivery fails
      NotificationJob.perform_later("student_unlinked", user_id, student_id)
    end

    # Notify remaining parents about this parent being unlinked (synchronous for reliability)
    # This ensures all remaining parents get notified immediately
    begin
      NotificationMailer.send_parent_unlinked_notifications(student, user)
    rescue => e
      Rails.logger.error "Failed to send parent unlinked notifications: #{e.message}"
      # Fallback to background job if synchronous delivery fails
      NotificationJob.perform_later("parent_unlinked", student_id, user_id)
    end
  end

  private
  # ----- Private Methods -----
  # None for now
end
