require "test_helper"

class AttendanceWorkflowTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = users(:admin_user)
    @regular_user = users(:regular_user)
    @event = events(:published_event)
    @student = students(:active_student_one)
  end

  test "admin can manage event attendance through full workflow" do
    # Admin logs in
    post session_url, params: {
      email_address: @admin_user.email_address,
      password: "password123"
    }
    assert_response :redirect
    follow_redirect!
    assert_response :success

    # Admin visits event page and sees attendance section
    get event_path(@event)
    assert_response :success
    assert_select "h5", "Event Attendance"
    assert_select "button[data-student-id='#{@student.id}']"

    # Admin toggles attendance via AJAX
    post event_toggle_attendance_path(@event, @student), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_equal "absent", json_response["status"] # Should toggle from present to absent
    assert_equal @admin_user.full_name, json_response["marked_by"]

    # Verify attendance was updated in database
    attendance = Attendance.find_by(event: @event, student: @student)
    assert_not_nil attendance
    assert_equal false, attendance.present
    assert_equal @admin_user, attendance.marked_by
  end

  test "regular user cannot access attendance management" do
    # Regular user logs in
    post session_url, params: {
      email_address: @regular_user.email_address,
      password: "password123"
    }
    assert_response :redirect
    follow_redirect!
    assert_response :success

    # Regular user visits event page but doesn't see attendance section
    get event_path(@event)
    assert_response :success
    assert_select "h5", { text: "Event Attendance", count: 0 }

    # Regular user cannot toggle attendance
    post event_toggle_attendance_path(@event, @student), as: :json
    assert_response :unauthorized

    json_response = JSON.parse(response.body)
    assert_equal false, json_response["success"]
    assert_equal "Unauthorized", json_response["error"]
  end

  test "unauthenticated user cannot access attendance features" do
    # Try to access event page (should work)
    get event_path(@event)
    assert_response :success
    assert_select "h5", { text: "Event Attendance", count: 0 }

    # Try to toggle attendance (should be unauthorized)
    post event_toggle_attendance_path(@event, @student), as: :json
    assert_response :unauthorized

    json_response = JSON.parse(response.body)
    assert_equal false, json_response["success"]
    assert_equal "Unauthorized", json_response["error"]
  end

  test "attendance data persists correctly across multiple toggles" do
    # Admin logs in
    post session_url, params: {
      email_address: @admin_user.email_address,
      password: "password123"
    }
    follow_redirect!

    student = students(:inactive_student) # Student with no existing attendance

    # First toggle - should create new record as present
    post event_toggle_attendance_path(@event, student), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_equal true, json_response["present"]
    assert_equal "present", json_response["status"]

    # Second toggle - should change to absent
    post event_toggle_attendance_path(@event, student), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_equal false, json_response["present"]
    assert_equal "absent", json_response["status"]

    # Third toggle - should change back to present
    post event_toggle_attendance_path(@event, student), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_equal true, json_response["present"]
    assert_equal "present", json_response["status"]

    # Verify only one attendance record exists for this student/event
    assert_equal 1, Attendance.where(event: @event, student: student).count

    # Verify final state in database
    attendance = Attendance.find_by(event: @event, student: student)
    assert attendance.present
    assert_equal @admin_user, attendance.marked_by
    assert_not_nil attendance.marked_at
  end
end
