class NotificationJob < ApplicationJob
  queue_as :notifications

  # Job to send new event notifications
  def perform(action, *args)
    case action
    when "new_event"
      event_id = args[0]
      event = Event.find(event_id)
      NotificationMailer.send_new_event_notifications(event)
    when "event_cancelled"
      event_id = args[0]
      event = Event.find(event_id)
      NotificationMailer.send_event_cancelled_notifications(event)
    when "event_updated"
      event_id, changed_fields = args
      event = Event.find(event_id)
      NotificationMailer.send_event_updated_notifications(event, changed_fields || [])
    when "student_linked"
      user_id, student_id = args
      user = User.find(user_id)
      student = Student.find(student_id)
      NotificationMailer.send_student_linked_notification(user, student)
    when "student_unlinked"
      user_id, student_id = args
      user = User.find(user_id)
      student = Student.find(student_id)
      NotificationMailer.send_student_unlinked_notification(user, student)
    when "student_attendance"
      student_id, event_id, attendance_id = args
      student = Student.find(student_id)
      event = Event.find(event_id)
      attendance = Attendance.find(attendance_id)
      NotificationMailer.send_student_attendance_notification(student, event, attendance)
    when "student_profile_updated"
      student_id, changed_fields = args
      student = Student.find(student_id)
      NotificationMailer.send_student_profile_updated_notifications(student, changed_fields || [])
    when "new_parent_linked"
      student_id, new_parent_id = args
      student = Student.find(student_id)
      new_parent = User.find(new_parent_id)
      NotificationMailer.send_new_parent_linked_notifications(student, new_parent)
    else
      Rails.logger.error "Unknown notification action: #{action}"
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "NotificationJob failed - Record not found: #{e.message}"
  rescue => e
    Rails.logger.error "NotificationJob failed: #{e.message}"
    raise e # Re-raise to trigger job retry
  end
end
