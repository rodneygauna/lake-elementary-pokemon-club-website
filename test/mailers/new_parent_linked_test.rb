require "test_helper"

class NewParentLinkedNotificationTest < ActionMailer::TestCase
  def setup
    @parent1 = users(:regular_user)
    @parent2 = users(:admin_user)
    @student = students(:one)

    EmailSubscription.destroy_all
  end

  test "new_parent_linked email contains correct information" do
    email = NotificationMailer.new_parent_linked(@parent1, @student, @parent2)

    assert_equal [ @parent1.email_address ], email.to
    assert_equal "👨‍👩‍👧‍👦 New Parent Added to #{@student.first_name}'s Account", email.subject
    assert_not email.body.to_s.blank?
    assert_match @student.first_name, email.body.to_s
    assert_match @parent2.first_name, email.body.to_s
    assert_match @parent2.email_address, email.body.to_s
  end

  test "new_parent_linked_notifications respects subscription preferences" do
    UserStudent.create!(user: @parent1, student: @student)
    EmailSubscription.create!(user: @parent1, subscription_type: "new_parent_linked", enabled: false)

    assert_emails 0 do
      NotificationMailer.send_new_parent_linked_notifications(@student, @parent2)
    end
  end
end
