require "test_helper"

class EmailNotificationIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin_user)
    @user = users(:regular_user)
    @student = students(:active_student_one)

    # Set up user subscriptions
    EmailSubscription.create!(user: @user, subscription_type: "new_events", enabled: true)
    EmailSubscription.create!(user: @user, subscription_type: "event_cancellations", enabled: true)
    EmailSubscription.create!(user: @user, subscription_type: "event_updates", enabled: true)
    EmailSubscription.create!(user: @user, subscription_type: "student_attendance_updates", enabled: true)
    EmailSubscription.create!(user: @user, subscription_type: "student_profile_updates", enabled: true)

    # Link user to student
    UserStudent.create!(user: @user, student: @student)
  end

  test "complete event workflow sends appropriate notifications" do
    # 1. Admin creates a new published event
    assert_emails 1 do
      post events_path, params: {
        event: {
          title: "Test Event",
          description: "Test event description",
          starts_at: 1.week.from_now,
          ends_at: 1.week.from_now + 2.hours,
          status: "published"
        }
      }
    end

    event = Event.last

    # 2. Admin updates the event
    assert_emails 1 do
      patch event_path(event), params: {
        event: {
          title: "Updated Test Event"
        }
      }
    end

    # 3. Admin cancels the event
    assert_emails 1 do
      patch event_path(event), params: {
        event: {
          status: "canceled"
        }
      }
    end
  end

  test "student management workflow sends appropriate notifications" do
    # 1. Create new student and link to user (should send linked notification)
    new_student = nil
    assert_emails 1 do
      new_student = Student.create!(
        first_name: "New",
        last_name: "Student",
        grade: "K",
        status: "active"
      )
      UserStudent.create!(user: @user, student: new_student)
    end

    # 2. Update student profile (should send profile update notification)
    assert_emails 1 do
      new_student.update!(first_name: "Updated", grade: "1")
    end

    # 3. Record attendance (should send attendance notification)
    event = Event.create!(
      title: "Test Event",
      starts_at: 1.week.from_now,
      ends_at: 1.week.from_now + 2.hours,
      status: "published"
    )

    assert_emails 1 do
      Attendance.create!(
        event: event,
        student: new_student,
        present: true,
        marked_by: @admin
      )
    end

    # 4. Unlink student (should send unlinked notification)
    user_student = UserStudent.find_by(user: @user, student: new_student)
    assert_emails 1 do
      user_student.destroy!
    end
  end

  test "email preferences can be updated through UI" do
    post session_path, params: {
      email_address: @user.email_address,
      password: "password123"
    }

    # Visit email preferences page
    get users_email_preferences_path
    assert_response :success

    # Update preferences to disable new events
    patch users_update_email_preferences_path, params: {
      email_subscriptions: {
        new_events: "0",
        event_cancellations: "1",
        event_updates: "1",
        student_attendance_updates: "1",
        student_profile_updates: "1"
      }
    }

    # Check that subscription was updated
    subscription = @user.email_subscriptions.find_by(subscription_type: "new_events")
    assert_not subscription.enabled?

    # Verify that no new event emails are sent
    assert_emails 0 do
      Event.create!(
        title: "Test Event",
        starts_at: 1.week.from_now,
        ends_at: 1.week.from_now + 2.hours,
        status: "published"
      )
    end
  end

  test "unsubscribed users do not receive notifications" do
    # Disable all subscriptions
    @user.email_subscriptions.update_all(enabled: false)

    # No emails should be sent for any action
    assert_emails 0 do
      # Create event
      Event.create!(
        title: "Test Event",
        starts_at: 1.week.from_now,
        ends_at: 1.week.from_now + 2.hours,
        status: "published"
      )

      # Update student
      @student.update!(first_name: "Updated Name")

      # Record attendance
      event = Event.last
      Attendance.create!(
        event: event,
        student: @student,
        present: true,
        marked_by: @admin
      )
    end
  end

  test "users without linked students do not receive student notifications" do
    # Remove student link
    UserStudent.where(user: @user).destroy_all

    # Should not receive student-related notifications
    assert_emails 0 do
      @student.update!(first_name: "Updated Name")
    end

    # But should still receive event notifications
    assert_emails 1 do
      Event.create!(
        title: "Test Event",
        starts_at: 1.week.from_now,
        ends_at: 1.week.from_now + 2.hours,
        status: "published"
      )
    end
  end

  test "email delivery includes proper Pokemon branding" do
    # Create an event to trigger email
    event = Event.create!(
      title: "Test Event",
      starts_at: 1.week.from_now,
      ends_at: 1.week.from_now + 2.hours,
      status: "published"
    )

    email = ActionMailer::Base.deliveries.last

    # Check subject line
    assert_equal "New Event: Test Event", email.subject
    assert_equal [ @user.email_address ], email.to

    # Check HTML content for Pokemon theme
    html_part = email.parts.find { |part| part.content_type.include?("html") }
    assert_match "#0084FF", html_part.body.to_s # Electric Blue
    assert_match "#FFD700", html_part.body.to_s # Pikachu Yellow
    assert_match "Pokemon Club", html_part.body.to_s

    # Check text content exists
    text_part = email.parts.find { |part| part.content_type.include?("plain") }
    assert_match "Test Event", text_part.body.to_s
  end

  private

  def login_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end
