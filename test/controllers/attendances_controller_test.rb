require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @event = events(:published_event)
    @student = students(:active_student_one)
    @admin_user = users(:admin_user)
    @super_user = users(:super_user)
    @regular_user = users(:regular_user)
  end

  # Helper method to sign in a user
  def sign_in_as(user)
    post session_url, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end

  # Test admin_level authorization
  test "should require admin_level access for toggle" do
    sign_in_as(@regular_user)

    post event_toggle_attendance_path(@event, @student), as: :json

    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "You must be an admin to access this page.", json_response["error"]
  end

  test "should allow admin access for toggle" do
    sign_in_as(@admin_user)

    post event_toggle_attendance_path(@event, students(:inactive_student)), as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal true, json_response["success"]
  end

  test "should allow super_user access for toggle" do
    sign_in_as(@super_user)

    post event_toggle_attendance_path(@event, students(:inactive_student)), as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal true, json_response["success"]
  end

  test "should require authentication for toggle" do
    post event_toggle_attendance_path(@event, @student), as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal false, json_response["success"]
    assert_equal "Unauthorized", json_response["error"]
  end

  # Test attendance toggle functionality
  test "should create new attendance record when none exists" do
    sign_in_as(@admin_user)

    assert_difference "Attendance.count", 1 do
      post event_toggle_attendance_path(@event, students(:inactive_student)), as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal true, json_response["success"]
    assert_equal true, json_response["present"]
    assert_equal "present", json_response["status"]
    assert_not_nil json_response["marked_at"]
    assert_equal @admin_user.full_name, json_response["marked_by"]
  end

  test "super_user should create new attendance record when none exists" do
    sign_in_as(@super_user)

    assert_difference "Attendance.count", 1 do
      post event_toggle_attendance_path(@event, students(:one)), as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal true, json_response["success"]
    assert_equal true, json_response["present"]
    assert_equal "present", json_response["status"]
    assert_not_nil json_response["marked_at"]
    assert_equal @super_user.full_name, json_response["marked_by"]
  end

  test "should toggle existing attendance record" do
    sign_in_as(@admin_user)

    # Use existing attendance record from fixtures (present_attendance)
    attendance = attendances(:present_attendance)
    assert_equal true, attendance.present  # Initially present

    assert_no_difference "Attendance.count" do
      post event_toggle_attendance_path(@event, @student), as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal true, json_response["success"]
    assert_equal false, json_response["present"]
    assert_equal "absent", json_response["status"]

    # Verify the attendance was toggled
    attendance.reload
    assert_equal false, attendance.present
  end

  test "should handle invalid event" do
    sign_in_as(@admin_user)

    post "/events/99999/attendances/toggle/#{@student.id}", as: :json

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal false, json_response["success"]
    assert_equal "Event not found", json_response["error"]
  end

  test "should handle invalid student" do
    sign_in_as(@admin_user)

    post "/events/#{@event.id}/attendances/toggle/99999", as: :json

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal false, json_response["success"]
    assert_equal "Student not found", json_response["error"]
  end

  # Note: Validation error testing is handled at the model level
  # Controller focuses on proper response formatting and authorization

  # Test that marking attendance updates the marked_by field
  test "should set marked_by to current admin user" do
    sign_in_as(@admin_user)

    post event_toggle_attendance_path(@event, students(:active_student_two)), as: :json

    assert_response :success

    # Find the created attendance record
    attendance = Attendance.find_by(event: @event, student: students(:active_student_two))
    assert_equal @admin_user, attendance.marked_by
  end

  test "should set marked_by to current super_user" do
    sign_in_as(@super_user)

    post event_toggle_attendance_path(@event, students(:test_student)), as: :json

    assert_response :success

    # Find the created attendance record
    attendance = Attendance.find_by(event: @event, student: students(:test_student))
    assert_equal @super_user, attendance.marked_by
  end
end
