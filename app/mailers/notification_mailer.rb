class NotificationMailer < ApplicationMailer
  default from: "Lake Elementary Pokémon Club <#{Rails.application.credentials.smtp&.user_name}>"

  # 3.1. New Event
  def new_event(user, event)
    @user = user
    @event = event
    @club_name = "Lake Elementary Pokémon Club"

    mail(
      to: @user.email_address,
      subject: "🌟 New Event: #{@event.title}"
    )
  end

  # 3.2. Event was cancelled
  def event_cancelled(user, event)
    @user = user
    @event = event
    @club_name = "Lake Elementary Pokémon Club"

    mail(
      to: @user.email_address,
      subject: "⚠️ Event Cancelled: #{@event.title}"
    )
  end

  # 3.3. Event was edited
  def event_updated(user, event, changed_fields = [])
    @user = user
    @event = event
    @changed_fields = changed_fields
    @club_name = "Lake Elementary Pokémon Club"

    mail(
      to: @user.email_address,
      subject: "📅 Event Updated: #{@event.title}"
    )
  end

  # 3.4. Student's attendance was updated
  def student_attendance_updated(user, student, event, attendance)
    @user = user
    @student = student
    @event = event
    @attendance = attendance
    @club_name = "Lake Elementary Pokémon Club"

    mail(
      to: @user.email_address,
      subject: "✅ Attendance Updated for #{@student.first_name}"
    )
  end

  # 3.5. Student was linked to user's account
  def student_linked(user, student)
    @user = user
    @student = student
    @club_name = "Lake Elementary Pokémon Club"

    mail(
      to: @user.email_address,
      subject: "👨‍👩‍👧‍👦 Student Added to Your Account: #{@student.first_name}"
    )
  end

  # 3.6. Student was unlinked from user's account
  def student_unlinked(user, student)
    @user = user
    @student = student
    @club_name = "Lake Elementary Pokémon Club"

    mail(
      to: @user.email_address,
      subject: "👋 Student Removed from Your Account: #{@student.first_name}"
    )
  end

  # 3.6.1. Another parent was unlinked from student
  def parent_unlinked(remaining_parent, student, unlinked_parent)
    @user = remaining_parent
    @student = student
    @unlinked_parent = unlinked_parent
    @club_name = "Lake Elementary Pokémon Club"

    mail(
      to: @user.email_address,
      subject: "👋 Parent Removed from #{@student.first_name}'s Account"
    )
  end

  # 3.7. Student's profile was updated
  def student_profile_updated(user, student, changed_fields = [])
    @user = user
    @student = student
    @changed_fields = changed_fields
    @club_name = "Lake Elementary Pokémon Club"

    mail(
      to: @user.email_address,
      subject: "📝 Profile Updated for #{@student.first_name}"
    )
  end

  # 3.8. New parent linked to student
  def new_parent_linked(existing_parent, student, new_parent)
    @existing_parent = existing_parent
    @student = student
    @new_parent = new_parent
    @club_name = "Lake Elementary Pokémon Club"

    mail(
      to: @existing_parent.email_address,
      subject: "👨‍👩‍👧‍👦 New Parent Added to #{@student.first_name}'s Account"
    )
  end

  # 3.9. User profile updated
  def user_profile_updated(user, changed_fields = [], changed_by_admin = false, admin_user = nil)
    @user = user
    @changed_fields = changed_fields
    @changed_by_admin = changed_by_admin
    @admin_user = admin_user
    @club_name = "Lake Elementary Pokémon Club"

    # Different subject line based on who made the change
    subject = if @changed_by_admin && @admin_user
      "🔒 Your Profile Was Updated by an Administrator"
    else
      "📝 Your Profile Has Been Updated"
    end

    mail(
      to: @user.email_address,
      subject: subject
    )
  end

  private

  # Helper method to get subscribed users for a notification type
  def self.users_subscribed_to(subscription_type)
    User.joins(:email_subscriptions)
        .where(email_subscriptions: { subscription_type: subscription_type, enabled: true })
        .where(status: "active")
  end

  # Helper method to send notifications to all subscribed users
  def self.notify_subscribed_users(subscription_type, &block)
    users_subscribed_to(subscription_type).find_each do |user|
      begin
        yield(user)
      rescue => e
        Rails.logger.error "Failed to send #{subscription_type} notification to user #{user.id}: #{e.message}"
      end
    end
  end

  # Bulk notification methods
  def self.send_new_event_notifications(event)
    notify_subscribed_users(:new_event) do |user|
      new_event(user, event).deliver_now
    end
  end

  def self.send_event_cancelled_notifications(event)
    notify_subscribed_users(:event_cancelled) do |user|
      event_cancelled(user, event).deliver_now
    end
  end

  def self.send_event_updated_notifications(event, changed_fields = [])
    notify_subscribed_users(:event_updated) do |user|
      event_updated(user, event, changed_fields).deliver_now
    end
  end

  # Individual user notification methods for student-specific notifications
  def self.send_student_attendance_notification(student, event, attendance)
    student.users.joins(:email_subscriptions)
           .where(email_subscriptions: { subscription_type: :student_attendance_updated, enabled: true })
           .where(status: "active")
           .find_each do |user|
      begin
        student_attendance_updated(user, student, event, attendance).deliver_now
      rescue => e
        Rails.logger.error "Failed to send attendance notification to user #{user.id}: #{e.message}"
      end
    end
  end

  def self.send_student_linked_notification(user, student)
    return unless user.subscribed_to?(:student_linked)

    begin
      NotificationMailer.student_linked(user, student).deliver_now
    rescue => e
      Rails.logger.error "Failed to send student linked notification to user #{user.id}: #{e.message}"
    end
  end

  def self.send_student_unlinked_notification(user, student)
    return unless user.subscribed_to?(:student_unlinked)

    begin
      NotificationMailer.student_unlinked(user, student).deliver_now
    rescue => e
      Rails.logger.error "Failed to send student unlinked notification to user #{user.id}: #{e.message}"
    end
  end

  def self.send_student_profile_updated_notifications(student, changed_fields = [])
    student.users.joins(:email_subscriptions)
           .where(email_subscriptions: { subscription_type: :student_profile_updated, enabled: true })
           .where(status: "active")
           .find_each do |user|
      begin
        student_profile_updated(user, student, changed_fields).deliver_now
      rescue => e
        Rails.logger.error "Failed to send student profile update notification to user #{user.id}: #{e.message}"
      end
    end
  end

  def self.send_new_parent_linked_notifications(student, new_parent)
    # Find existing parents (excluding the newly linked parent)
    existing_parents = student.users.joins(:email_subscriptions)
                              .where(email_subscriptions: { subscription_type: :new_parent_linked, enabled: true })
                              .where(status: "active")
                              .where.not(id: new_parent.id)

    existing_parents.find_each do |existing_parent|
      begin
        new_parent_linked(existing_parent, student, new_parent).deliver_now
      rescue => e
        Rails.logger.error "Failed to send new parent linked notification to user #{existing_parent.id}: #{e.message}"
      end
    end
  end

  def self.send_parent_unlinked_notifications(student, unlinked_parent)
    # Find remaining parents (excluding the unlinked parent)
    remaining_parents = student.users.joins(:email_subscriptions)
                               .where(email_subscriptions: { subscription_type: :parent_unlinked, enabled: true })
                               .where(status: "active")
                               .where.not(id: unlinked_parent.id)

    remaining_parents.find_each do |remaining_parent|
      begin
        parent_unlinked(remaining_parent, student, unlinked_parent).deliver_now
      rescue => e
        Rails.logger.error "Failed to send parent unlinked notification to user #{remaining_parent.id}: #{e.message}"
      end
    end
  end
end
