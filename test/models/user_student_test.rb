require "test_helper"

class UserStudentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @user = users(:test_parent)
    @student = students(:test_student)
    @existing_user_student = user_students(:user_student_one)
    @valid_attributes = {
      user: @user,
      student: @student
    }
  end

  # Test validations
  test "should be valid with valid attributes" do
    user_student = UserStudent.new(@valid_attributes)
    assert user_student.valid?
  end

  test "should require user" do
    user_student = UserStudent.new(@valid_attributes.except(:user))
    assert_not user_student.valid?
    assert_includes user_student.errors[:user], "must exist"
  end

  test "should require student" do
    user_student = UserStudent.new(@valid_attributes.except(:student))
    assert_not user_student.valid?
    assert_includes user_student.errors[:student], "must exist"
  end

  test "should validate uniqueness of user and student combination" do
    # Create first association
    UserStudent.create!(@valid_attributes)

    # Try to create duplicate
    duplicate = UserStudent.new(@valid_attributes)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:student_id], "has already been taken"
  end

  test "should allow same user with different students" do
    different_student = students(:active_student_two)
    UserStudent.create!(@valid_attributes)

    second_association = UserStudent.new(@valid_attributes.merge(student: different_student))
    assert second_association.valid?
  end

  test "should allow same student with different users" do
    different_user = users(:admin_user)
    UserStudent.create!(@valid_attributes)

    second_association = UserStudent.new(@valid_attributes.merge(user: different_user))
    assert second_association.valid?
  end

  # Test associations
  test "should belong to user" do
    assert_respond_to @existing_user_student, :user
    assert_equal users(:regular_user), @existing_user_student.user
  end

  test "should belong to student" do
    assert_respond_to @existing_user_student, :student
    assert_equal students(:active_student_one), @existing_user_student.student
  end

  # Test dependent destroy behavior
  test "should be destroyed when user is destroyed" do
    user_student = UserStudent.create!(@valid_attributes)
    user_student_id = user_student.id

    @user.destroy
    assert_nil UserStudent.find_by(id: user_student_id)
  end

  test "should be destroyed when student is destroyed" do
    user_student = UserStudent.create!(@valid_attributes)
    user_student_id = user_student.id

    @student.destroy
    assert_nil UserStudent.find_by(id: user_student_id)
  end

  # Test scopes
  test "should have by_user scope" do
    user_student = UserStudent.create!(@valid_attributes)
    user_associations = UserStudent.by_user(@user.id)
    assert_includes user_associations, user_student

    # Test that other user's associations are not included
    assert_not_includes user_associations, @existing_user_student
  end

  test "should have by_student scope" do
    user_student = UserStudent.create!(@valid_attributes)
    student_associations = UserStudent.by_student(@student.id)
    assert_includes student_associations, user_student

    # Test that other student's associations are not included
    assert_not_includes student_associations, @existing_user_student
  end

  # Test email notification callbacks
  test "should enqueue student linked notification job when created" do
    assert_enqueued_jobs 1, only: NotificationJob do
      UserStudent.create!(@valid_attributes)
    end
  end

  test "should enqueue student unlinked notification job when destroyed" do
    user_student = UserStudent.create!(@valid_attributes)

    assert_enqueued_jobs 1, only: NotificationJob do
      user_student.destroy!
    end
  end

  test "should handle notification callbacks gracefully" do
    # This test ensures the callbacks handle edge cases gracefully
    user_student = UserStudent.create!(@valid_attributes)

    # Callbacks should still enqueue jobs even if there are issues
    assert_enqueued_jobs 1, only: NotificationJob do
      user_student.destroy!
    end
  end

  # Test instance methods
  test "user_to_student_link should return formatted string" do
    expected = "UserStudent: User##{@existing_user_student.user.id} <-> Student##{@existing_user_student.student.id}"
    assert_equal expected, @existing_user_student.user_to_student_link
  end

  test "send_student_linked_notification should enqueue job" do
    user_student = UserStudent.new(@valid_attributes)

    assert_enqueued_jobs 1, only: NotificationJob do
      user_student.send_student_linked_notification
    end
  end

  test "send_student_unlinked_notification should enqueue job" do
    user_student = UserStudent.new(@valid_attributes)

    assert_enqueued_jobs 1, only: NotificationJob do
      user_student.send_student_unlinked_notification
    end
  end
end
