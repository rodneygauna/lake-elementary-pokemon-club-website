require "test_helper"

class StudentTest < ActiveSupport::TestCase
  def setup
    @active_student = students(:active_student_one)
    @inactive_student = students(:inactive_student)
    @valid_attributes = {
      first_name: "Test",
      last_name: "Student",
      grade: "3",
      status: "active"
    }
  end

  # Test validations
  test "should be valid with valid attributes" do
    student = Student.new(@valid_attributes)
    assert student.valid?
  end

  test "should require first_name" do
    student = Student.new(@valid_attributes.except(:first_name))
    assert_not student.valid?
    assert_includes student.errors[:first_name], "can't be blank"
  end

  test "should require last_name" do
    student = Student.new(@valid_attributes.except(:last_name))
    assert_not student.valid?
    assert_includes student.errors[:last_name], "can't be blank"
  end

  # Test enums
  test "should have status enum" do
    assert_equal "active", @active_student.status
    assert_equal "inactive", @inactive_student.status
    assert @active_student.active?
    assert @inactive_student.inactive?
  end

  test "should have grade enum" do
    assert_equal "third_grade", @active_student.grade
    assert @active_student.third_grade?
  end

  # Test associations
  test "should have many user_students" do
    assert_respond_to @active_student, :user_students
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @active_student.user_students
  end

  test "should have many users through user_students" do
    assert_respond_to @active_student, :users
  end

  test "should have many attendances" do
    assert_respond_to @active_student, :attendances
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @active_student.attendances
  end

  test "should have many attended_events" do
    assert_respond_to @active_student, :attended_events
  end

  # Test scopes
  test "active scope should return active students" do
    active_students = Student.active
    assert_includes active_students, @active_student
    assert_not_includes active_students, @inactive_student
  end

  test "inactive scope should return inactive students" do
    inactive_students = Student.inactive
    assert_includes inactive_students, @inactive_student
    assert_not_includes inactive_students, @active_student
  end

  test "by_last_name scope should order by last name then first name" do
    students = Student.by_last_name
    assert_equal students.first.last_name, students.to_a.min_by(&:last_name).last_name
  end

  test "search scope should find students by name" do
    results = Student.search("Alex")
    assert_includes results, @active_student

    results = Student.search("Johnson")
    assert_includes results, @active_student
  end

  # Test instance methods
  test "full_name should combine first and last name" do
    assert_equal "Alex Johnson", @active_student.full_name
  end

  test "initials should return first letters of names" do
    assert_equal "AJ", @active_student.initials
  end

  test "display_name_for should return full name for admin" do
    admin = users(:admin_user)
    assert_equal @active_student.full_name, @active_student.display_name_for(admin)
  end

  test "display_name_for should return initials for non-linked users" do
    # Create a user that's not linked to this student
    unlinked_user = User.create!(
      first_name: "Unlinked",
      last_name: "User",
      email_address: "unlinked@test.com",
      password: "password123",
      role: "user",
      status: "active"
    )
    assert_equal @active_student.initials, @active_student.display_name_for(unlinked_user)
  end

  test "active_for_authentication should return true for active students" do
    assert @active_student.active_for_authentication?
    assert_not @inactive_student.active_for_authentication?
  end

  test "inactive_message should return message for inactive students" do
    message = @inactive_student.inactive_message
    assert_includes message, "inactive"
  end

  # Test email notification callbacks
  test "should send profile update notifications when significant fields change" do
    user = users(:regular_user)
    UserStudent.create!(user: user, student: @active_student)
    EmailSubscription.create!(user: user, subscription_type: "student_profile_updates", enabled: true)

    assert_emails 1 do
      @active_student.update!(first_name: "Updated Name")
    end
  end

  test "should send notifications for multiple significant field changes" do
    user = users(:regular_user)
    UserStudent.create!(user: user, student: @active_student)
    EmailSubscription.create!(user: user, subscription_type: "student_profile_updates", enabled: true)

    assert_emails 1 do
      @active_student.update!(first_name: "New First", last_name: "New Last", grade: "4")
    end
  end

  test "should not send notifications when no significant fields change" do
    user = users(:regular_user)
    UserStudent.create!(user: user, student: @active_student)
    EmailSubscription.create!(user: user, subscription_type: "student_profile_updates", enabled: true)

    assert_emails 0 do
      @active_student.update!(status: "active") # Same value, no change
    end
  end

  test "should not send notifications for insignificant field changes" do
    user = users(:regular_user)
    UserStudent.create!(user: user, student: @active_student)
    EmailSubscription.create!(user: user, subscription_type: "student_profile_updates", enabled: true)

    assert_emails 0 do
      @active_student.update!(teacher_name: "New Teacher") # Not in significant_changes list
    end
  end

  test "should not send notifications when no linked parents" do
    # Student has no linked users
    assert_emails 0 do
      @active_student.update!(first_name: "Updated Name")
    end
  end

  test "should send notifications to multiple linked parents" do
    user1 = users(:regular_user)
    user2 = users(:admin_user)
    UserStudent.create!(user: user1, student: @active_student)
    UserStudent.create!(user: user2, student: @active_student)
    EmailSubscription.create!(user: user1, subscription_type: "student_profile_updates", enabled: true)
    EmailSubscription.create!(user: user2, subscription_type: "student_profile_updates", enabled: true)

    assert_emails 2 do
      @active_student.update!(grade: "4")
    end
  end
end
