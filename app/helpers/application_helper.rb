module ApplicationHelper
  def subscription_type_title(type_key)
    case type_key.to_s
    when "new_event"
      "New Event Announcements"
    when "event_cancelled"
      "Event Cancellations"
    when "event_updated"
      "Event Updates"
    when "student_attendance_updated"
      "Student Attendance Updates"
    when "student_linked"
      "Student Added to Account"
    when "student_unlinked"
      "Student Removed from Account"
    when "student_profile_updated"
      "Student Profile Changes"
    when "new_parent_linked"
      "New Parent Added"
    when "parent_unlinked"
      "Parent Removed"
    else
      type_key.humanize
    end
  end

  def subscription_type_description(type_key)
    case type_key.to_s
    when "new_event"
      "Get notified when new club events are announced"
    when "event_cancelled"
      "Receive important alerts when events are cancelled"
    when "event_updated"
      "Stay informed about changes to event details (time, location, etc.)"
    when "student_attendance_updated"
      "Know when your student's attendance is marked for club events"
    when "student_linked"
      "Get notified when a student is added to your account"
    when "student_unlinked"
      "Receive alerts when a student is removed from your account"
    when "student_profile_updated"
      "Stay updated when your student's profile information changes"
    when "new_parent_linked"
      "Get notified when another parent is linked to your student"
    when "parent_unlinked"
      "Receive alerts when another parent is removed from your student"
    else
      "Receive notifications for #{type_key.humanize.downcase}"
    end
  end
end
