require "test_helper"

class NotificationJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  def setup
    # Clear any previous data
    ActionMailer::Base.deliveries.clear
    EmailSubscription.delete_all

    @user = users(:regular_user)
    @student = students(:test_student)
    @event = events(:published_event)
    @attendance = attendances(:present_attendance)
  end

  def teardown
    ActionMailer::Base.deliveries.clear
  end

  test "should perform new_event action" do
    # Set up only one user subscription
    EmailSubscription.create!(user: @user, subscription_type: "new_event", enabled: true)

    perform_enqueued_jobs do
      NotificationJob.perform_later("new_event", @event.id)
    end

    assert_emails 1
  end

  test "should perform event_cancelled action" do
    # Set up user subscription
    EmailSubscription.create!(user: @user, subscription_type: "event_cancelled", enabled: true)

    perform_enqueued_jobs do
      NotificationJob.perform_later("event_cancelled", @event.id)
    end

    assert_emails 1
  end

  test "should perform event_updated action" do
    # Set up user subscription
    EmailSubscription.create!(user: @user, subscription_type: "event_updated", enabled: true)

    perform_enqueued_jobs do
      NotificationJob.perform_later("event_updated", @event.id, [ "title" ])
    end

    assert_emails 1
  end

  test "should perform student_linked action" do
    # Set up user subscription
    EmailSubscription.create!(user: @user, subscription_type: "student_linked", enabled: true)

    perform_enqueued_jobs do
      NotificationJob.perform_later("student_linked", @user.id, @student.id)
    end

    assert_emails 1
  end

  test "should perform student_unlinked action" do
    # Set up user subscription
    EmailSubscription.create!(user: @user, subscription_type: "student_unlinked", enabled: true)

    perform_enqueued_jobs do
      NotificationJob.perform_later("student_unlinked", @user.id, @student.id)
    end

    assert_emails 1
  end

  test "should perform student_attendance action" do
    # Set up user subscription
    EmailSubscription.create!(user: @user, subscription_type: "student_attendance_updated", enabled: true)

    perform_enqueued_jobs do
      NotificationJob.perform_later("student_attendance", @student.id, @event.id, @attendance.id)
    end

    assert_emails 1
  end

  test "should perform student_profile_updated action" do
    # Set up user subscription
    EmailSubscription.create!(user: @user, subscription_type: "student_profile_updated", enabled: true)

    perform_enqueued_jobs do
      NotificationJob.perform_later("student_profile_updated", @student.id, [ "first_name" ])
    end

    assert_emails 1
  end

  test "should handle unknown action gracefully" do
    assert_nothing_raised do
      perform_enqueued_jobs do
        NotificationJob.perform_later("unknown_action", @event.id)
      end
    end

    assert_emails 0
  end

  test "should handle missing records gracefully" do
    # This should not raise an error, just log it
    assert_nothing_raised do
      perform_enqueued_jobs do
        NotificationJob.perform_later("new_event", 99999) # Non-existent event ID
      end
    end

    assert_emails 0
  end

  test "should be enqueued on notifications queue" do
    assert_enqueued_with(job: NotificationJob, queue: "notifications") do
      NotificationJob.perform_later("new_event", @event.id)
    end
  end
end
