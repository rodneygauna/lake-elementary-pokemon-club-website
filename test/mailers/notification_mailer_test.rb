require "test_helper"require "test_helper"require "test_helper"



class NotificationMailerTest < ActionMailer::TestCase

  def setup

    @user = users(:regular_user)class NotificationMailerTest < ActionMailer::TestCaseclass NotificationMailerTest < ActionMailer::TestCase

    @admin = users(:admin_user)

    @event = events(:one)  def setup  def setup

    @student = students(:one)

    @attendance = attendances(:present_attendance)    @user = users(:regular_user)    @user = users(:regular_user)



    # Clear any existing subscriptions to avoid validation errors    @admin = users(:admin_user)    @admin = users(:admin_user)

    EmailSubscription.destroy_all

  end    @event = events(:one)    @event = events(:one)



  # Test individual mailer methods    @student = students(:one)    @student = students(:one)

  test "new_event generates email with correct content" do

    email = NotificationMailer.new_event(@user, @event)    @attendance = attendances(:present_attendance)    @attendance = attendances(:present_attendance)



    assert_emails 1 do

      email.deliver_now

    end    # Clear any existing subscriptions to avoid validation errors    # Clear any existing subscriptions to avoid validation errors



    assert_equal [@user.email_address], email.to    EmailSubscription.destroy_all    EmailSubscription.destroy_all

    assert_equal "🌟 New Event: #{@event.title}", email.subject

    # Check that the email has content (body is not empty)  end  end

    assert_not email.body.to_s.blank?, "Email body should not be blank"

    assert_match @event.title, email.body.to_s

  end

  # Test individual mailer methods  # Test individual mailer methods

  test "event_cancelled generates email with correct content" do

    @event.update!(status: "canceled")  test "new_event generates email with correct content" do  test "new_event generates email with correct content" do

    email = NotificationMailer.event_cancelled(@user, @event)

    email = NotificationMailer.new_event(@user, @event)    email = NotificationMailer.new_event(@user, @event)

    assert_emails 1 do

      email.deliver_now

    end

    assert_emails 1 do    assert_emails 1 do

    assert_equal [@user.email_address], email.to

    assert_equal "⚠️ Event Cancelled: #{@event.title}", email.subject      email.deliver_now      email.deliver_now

    assert_not email.body.to_s.blank?

    assert_match @event.title, email.body.to_s    end    end

  end



  test "student_linked generates email with correct content" do

    email = NotificationMailer.student_linked(@user, @student)    assert_equal [@user.email_address], email.to    assert_equal [@user.email_address], email.to



    assert_emails 1 do    assert_equal "🌟 New Event: #{@event.title}", email.subject    assert_equal "🌟 New Event: #{@event.title}", email.subject

      email.deliver_now

    end    # Check that the email has content (body is not empty)    assert_match @event.title, email.body.to_s



    assert_equal [@user.email_address], email.to    assert_not email.body.to_s.blank?, "Email body should not be blank"    assert_match "Pokemon", email.body.to_s # Pokemon theme - case sensitive

    assert_equal "👨‍👩‍👧‍👦 Student Added to Your Account: #{@student.first_name}", email.subject

    assert_not email.body.to_s.blank?    assert_match @event.title, email.body.to_s    assert_match "Electric Blue", email.body.to_s # Pokemon theme

    assert_match @student.first_name, email.body.to_s

  end  end  end



  # Test bulk notification class methods

  test "send_new_event_notifications sends to subscribed users only" do

    # Create email subscriptions for testing  test "event_cancelled generates email with correct content" do  test "event_cancelled generates email with correct content" do

    EmailSubscription.create!(user: @user, subscription_type: "new_event", enabled: true)

    EmailSubscription.create!(user: @admin, subscription_type: "new_event", enabled: false)    @event.update!(status: "canceled")    @event.update!(status: "canceled")



    assert_emails 1 do    email = NotificationMailer.event_cancelled(@user, @event)    email = NotificationMailer.event_cancelled(@user, @event)

      NotificationMailer.send_new_event_notifications(@event)

    end

  end

    assert_emails 1 do    assert_emails 1 do

  test "send_student_linked_notification sends to specific user" do

    assert_emails 1 do      email.deliver_now      email.deliver_now

      NotificationMailer.send_student_linked_notification(@user, @student)

    end    end    end

  end



  # Test email format (both HTML and text)

  test "emails include both HTML and text parts" do    assert_equal [@user.email_address], email.to    assert_equal [ @user.email_address ], email.to

    email = NotificationMailer.new_event(@user, @event)

    assert_equal "⚠️ Event Cancelled: #{@event.title}", email.subject    assert_equal "⚠️ Event Cancelled: #{@event.title}", email.subject

    assert_equal 2, email.parts.size

    assert_includes email.parts.map(&:content_type), "text/html; charset=UTF-8"    assert_not email.body.to_s.blank?    assert_match "has been cancelled", email.body.to_s

    assert_includes email.parts.map(&:content_type), "text/plain; charset=UTF-8"

  end    assert_match @event.title, email.body.to_s    assert_match @event.title, email.body.to_s



  test "HTML emails include Pokemon theme styling" do  end  end

    email = NotificationMailer.new_event(@user, @event)

    html_part = email.parts.find { |part| part.content_type.include?("html") }



    assert_match "#0084FF", html_part.body.to_s # Electric Blue  test "event_updated generates email with correct content" do  test "event_updated generates email with correct content" do

    assert_match "#FFD700", html_part.body.to_s # Pikachu Yellow

    assert_match "Pokémon", html_part.body.to_s # Pokemon with accent    changed_fields = ["title", "starts_at"]    changed_fields = [ "title", "starts_at" ]

  end

    email = NotificationMailer.event_updated(@user, @event, changed_fields)    email = NotificationMailer.event_updated(@user, @event, changed_fields)

  test "respects user email subscription preferences" do

    # User not subscribed to new events

    EmailSubscription.create!(user: @user, subscription_type: "new_event", enabled: false)

    assert_emails 1 do    assert_emails 1 do

    assert_emails 0 do

      NotificationMailer.send_new_event_notifications(@event)      email.deliver_now      email.deliver_now

    end

  end    end    end

end


    assert_equal [@user.email_address], email.to    assert_equal [ @user.email_address ], email.to

    assert_equal "📅 Event Updated: #{@event.title}", email.subject    assert_equal "📅 Event Updated: #{@event.title}", email.subject

    assert_not email.body.to_s.blank?    assert_match "has been updated", email.body.to_s

    assert_match @event.title, email.body.to_s    assert_match "title", email.body.to_s

  end    assert_match "starts_at", email.body.to_s

  end

  test "student_attendance_updated generates email with correct content" do

    email = NotificationMailer.student_attendance_updated(@user, @student, @event, true)  test "student_attendance_updated generates email with correct content" do

    email = NotificationMailer.student_attendance_updated(@user, @student, @event, @attendance.present?)

    assert_emails 1 do

      email.deliver_now    assert_emails 1 do

    end      email.deliver_now

    end

    assert_equal [@user.email_address], email.to

    assert_equal "✅ Attendance Updated for #{@student.first_name}", email.subject    assert_equal [ @user.email_address ], email.to

    assert_not email.body.to_s.blank?    assert_equal "✅ Attendance Updated for #{@student.first_name}", email.subject

    assert_match @student.first_name, email.body.to_s    assert_match @student.first_name, email.body.to_s

    assert_match @event.title, email.body.to_s    assert_match @event.title, email.body.to_s

  end  end



  test "student_linked generates email with correct content" do  test "student_linked generates email with correct content" do

    email = NotificationMailer.student_linked(@user, @student)    email = NotificationMailer.student_linked(@user, @student)



    assert_emails 1 do    assert_emails 1 do

      email.deliver_now      email.deliver_now

    end    end



    assert_equal [@user.email_address], email.to    assert_equal [ @user.email_address ], email.to

    assert_equal "👨‍👩‍👧‍👦 Student Added to Your Account: #{@student.first_name}", email.subject    assert_equal "👨‍👩‍👧‍👦 Student Added to Your Account: #{@student.first_name}", email.subject

    assert_not email.body.to_s.blank?    assert_match @student.first_name, email.body.to_s

    assert_match @student.first_name, email.body.to_s    assert_match "has been linked", email.body.to_s

  end  end



  test "student_unlinked generates email with correct content" do  test "student_unlinked generates email with correct content" do

    email = NotificationMailer.student_unlinked(@user, @student)    email = NotificationMailer.student_unlinked(@user, @student)



    assert_emails 1 do    assert_emails 1 do

      email.deliver_now      email.deliver_now

    end    end



    assert_equal [@user.email_address], email.to    assert_equal [ @user.email_address ], email.to

    assert_equal "👋 Student Removed from Your Account: #{@student.first_name}", email.subject    assert_equal "👋 Student Removed from Your Account: #{@student.first_name}", email.subject

    assert_not email.body.to_s.blank?    assert_match @student.first_name, email.body.to_s

    assert_match @student.first_name, email.body.to_s    assert_match "has been unlinked", email.body.to_s

  end  end



  test "student_profile_updated generates email with correct content" do  test "student_profile_updated generates email with correct content" do

    changed_fields = ["first_name", "grade"]    changed_fields = [ "first_name", "grade" ]

    email = NotificationMailer.student_profile_updated(@user, @student, changed_fields)    email = NotificationMailer.student_profile_updated(@user, @student, changed_fields)



    assert_emails 1 do    assert_emails 1 do

      email.deliver_now      email.deliver_now

    end    end



    assert_equal [@user.email_address], email.to    assert_equal [ @user.email_address ], email.to

    assert_equal "📝 Profile Updated for #{@student.first_name}", email.subject    assert_equal "📝 Student Profile Updated: #{@student.first_name}", email.subject

    assert_not email.body.to_s.blank?    assert_match @student.first_name, email.body.to_s

    assert_match @student.first_name, email.body.to_s    assert_match "first_name", email.body.to_s

  end    assert_match "grade", email.body.to_s

  end

  # Test bulk notification class methods

  test "send_new_event_notifications sends to subscribed users only" do  # Test bulk notification class methods

    # Create email subscriptions for testing  test "send_new_event_notifications sends to subscribed users only" do

    EmailSubscription.create!(user: @user, subscription_type: "new_event", enabled: true)    # Create email subscriptions for testing

    EmailSubscription.create!(user: @admin, subscription_type: "new_event", enabled: false)    EmailSubscription.create!(user: @user, subscription_type: "new_event", enabled: true)

    EmailSubscription.create!(user: @admin, subscription_type: "new_event", enabled: false)

    assert_emails 1 do

      NotificationMailer.send_new_event_notifications(@event)    assert_emails 1 do

    end      NotificationMailer.send_new_event_notifications(@event)

  end    end

  end

  test "send_event_cancelled_notifications sends to subscribed users only" do

    EmailSubscription.create!(user: @user, subscription_type: "event_cancelled", enabled: true)  test "send_event_cancelled_notifications sends to subscribed users only" do

    EmailSubscription.create!(user: @admin, subscription_type: "event_cancelled", enabled: false)    EmailSubscription.create!(user: @user, subscription_type: "event_cancelled", enabled: true)

    EmailSubscription.create!(user: @admin, subscription_type: "event_cancelled", enabled: false)

    assert_emails 1 do

      NotificationMailer.send_event_cancelled_notifications(@event)    assert_emails 1 do

    end      NotificationMailer.send_event_cancelled_notifications(@event)

  end    end

  end

  test "send_event_updated_notifications sends to subscribed users only" do

    EmailSubscription.create!(user: @user, subscription_type: "event_updated", enabled: true)  test "send_event_updated_notifications sends to subscribed users only" do

    changed_fields = ["title"]    EmailSubscription.create!(user: @user, subscription_type: "event_updated", enabled: true)

    changed_fields = [ "title" ]

    assert_emails 1 do

      NotificationMailer.send_event_updated_notifications(@event, changed_fields)    assert_emails 1 do

    end      NotificationMailer.send_event_updated_notifications(@event, changed_fields)

  end    end

  end

  test "send_student_attendance_notification sends to linked parents only" do

    # Link user to student  test "send_student_attendance_notification sends to linked parents only" do

    UserStudent.create!(user: @user, student: @student)    # Link user to student

    EmailSubscription.create!(user: @user, subscription_type: "student_attendance_updated", enabled: true)    UserStudent.create!(user: @user, student: @student)

    EmailSubscription.create!(user: @user, subscription_type: "student_attendance_updated", enabled: true)

    assert_emails 1 do

      NotificationMailer.send_student_attendance_notification(@student, @event, true)    assert_emails 1 do

    end      NotificationMailer.send_student_attendance_notification(@student, @event, true)

  end    end

  end

  test "send_student_linked_notification sends to specific user" do

    assert_emails 1 do  test "send_student_linked_notification sends to specific user" do

      NotificationMailer.send_student_linked_notification(@user, @student)    assert_emails 1 do

    end      NotificationMailer.send_student_linked_notification(@user, @student)

  end    end

  end

  test "send_student_unlinked_notification sends to specific user" do

    assert_emails 1 do  test "send_student_unlinked_notification sends to specific user" do

      NotificationMailer.send_student_unlinked_notification(@user, @student)    assert_emails 1 do

    end      NotificationMailer.send_student_unlinked_notification(@user, @student)

  end    end

  end

  test "send_student_profile_updated_notifications sends to linked parents only" do

    UserStudent.create!(user: @user, student: @student)  test "send_student_profile_updated_notifications sends to linked parents only" do

    EmailSubscription.create!(user: @user, subscription_type: "student_profile_updated", enabled: true)    UserStudent.create!(user: @user, student: @student)

    changed_fields = ["first_name"]    EmailSubscription.create!(user: @user, subscription_type: "student_profile_updated", enabled: true)

    changed_fields = [ "first_name" ]

    assert_emails 1 do

      NotificationMailer.send_student_profile_updated_notifications(@student, changed_fields)    assert_emails 1 do

    end      NotificationMailer.send_student_profile_updated_notifications(@student, changed_fields)

  end    end

  end

  # Test email format (both HTML and text)

  test "emails include both HTML and text parts" do  # Test email format (both HTML and text)

    email = NotificationMailer.new_event(@user, @event)  test "emails include both HTML and text parts" do

    email = NotificationMailer.new_event(@user, @event)

    assert_equal 2, email.parts.size

    assert_includes email.parts.map(&:content_type), "text/html; charset=UTF-8"    assert_equal 2, email.parts.size

    assert_includes email.parts.map(&:content_type), "text/plain; charset=UTF-8"    assert_includes email.parts.map(&:content_type), "text/html; charset=UTF-8"

  end    assert_includes email.parts.map(&:content_type), "text/plain; charset=UTF-8"

  end

  test "HTML emails include Pokemon theme styling" do

    email = NotificationMailer.new_event(@user, @event)  test "HTML emails include Pokemon theme styling" do

    html_part = email.parts.find { |part| part.content_type.include?("html") }    email = NotificationMailer.new_event(@user, @event)

    html_part = email.parts.find { |part| part.content_type.include?("html") }

    assert_match "#0084FF", html_part.body.to_s # Electric Blue

    assert_match "#FFD700", html_part.body.to_s # Pikachu Yellow    assert_match "#0084FF", html_part.body.to_s # Electric Blue

    assert_match "Pokémon", html_part.body.to_s # Pokemon with accent    assert_match "#FFD700", html_part.body.to_s # Pikachu Yellow

  end    assert_match "Pokemon", html_part.body.to_s

  end

  test "respects user email subscription preferences" do

    # User not subscribed to new events  test "respects user email subscription preferences" do

    EmailSubscription.create!(user: @user, subscription_type: "new_event", enabled: false)    # User not subscribed to new events

    EmailSubscription.create!(user: @user, subscription_type: "new_event", enabled: false)

    assert_emails 0 do

      NotificationMailer.send_new_event_notifications(@event)    assert_emails 0 do

    end      NotificationMailer.send_new_event_notifications(@event)

  end    end

end  end
end
