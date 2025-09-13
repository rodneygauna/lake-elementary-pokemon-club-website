require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  def setup
    @attendance = attendances(:present_attendance)
    @event = events(:published_event)
    @student = students(:active_student_one)
    @admin = users(:admin_user)
  end

  # Test validations
  test "should be valid with valid attributes" do
    assert @attendance.valid?
  end

  test "should require event" do
    @attendance.event = nil
    assert_not @attendance.valid?
    assert_includes @attendance.errors[:event], "must exist"
  end

  test "should require student" do
    @attendance.student = nil
    assert_not @attendance.valid?
    assert_includes @attendance.errors[:student], "must exist"
  end

  test "should require marked_by" do
    @attendance.marked_by = nil
    assert_not @attendance.valid?
    assert_includes @attendance.errors[:marked_by], "must exist"
  end

  test "should validate present field inclusion" do
    @attendance.present = nil
    assert_not @attendance.valid?
    assert_includes @attendance.errors[:present], "is not included in the list"
  end

  test "should enforce unique student per event" do
    duplicate_attendance = Attendance.new(
      event: @attendance.event,
      student: @attendance.student,
      marked_by: @admin,
      present: false
    )
    assert_not duplicate_attendance.valid?
    assert_includes duplicate_attendance.errors[:student_id], "can only have one attendance record per event"
  end

  # Test associations
  test "should belong to event" do
    assert_equal @event, @attendance.event
  end

  test "should belong to student" do
    assert_equal @student, @attendance.student
  end

  test "should belong to marked_by user" do
    assert_equal @admin, @attendance.marked_by
  end

  # Test scopes
  test "present scope should return present attendances" do
    present_attendances = Attendance.present
    assert_includes present_attendances, attendances(:present_attendance)
    assert_not_includes present_attendances, attendances(:absent_attendance)
  end

  test "absent scope should return absent attendances" do
    absent_attendances = Attendance.absent
    assert_includes absent_attendances, attendances(:absent_attendance)
    assert_not_includes absent_attendances, attendances(:present_attendance)
  end

  test "for_event scope should return attendances for specific event" do
    event_attendances = Attendance.for_event(@event)
    assert_includes event_attendances, @attendance
  end

  test "for_student scope should return attendances for specific student" do
    student_attendances = Attendance.for_student(@student)
    assert_includes student_attendances, @attendance
  end

  # Test instance methods
  test "toggle_presence! should toggle present status and update marked_at" do
    original_present = @attendance.present
    original_marked_at = @attendance.marked_at

    @attendance.toggle_presence!

    assert_equal !original_present, @attendance.present
    assert_not_equal original_marked_at, @attendance.marked_at
  end

  test "status should return correct string" do
    @attendance.present = true
    assert_equal "present", @attendance.status

    @attendance.present = false
    assert_equal "absent", @attendance.status
  end

  test "marked_by_name should return admin full name" do
    assert_equal @admin.full_name, @attendance.marked_by_name
  end

  test "marked_by_name should return Unknown when marked_by is nil" do
    @attendance.marked_by = nil
    assert_equal "Unknown", @attendance.marked_by_name
  end

  # Test callbacks
  test "should set marked_at when present changes" do
    @attendance.present = false
    original_marked_at = @attendance.marked_at

    travel_to 1.hour.from_now do
      @attendance.save!
      assert_not_equal original_marked_at, @attendance.marked_at
    end
  end
end
