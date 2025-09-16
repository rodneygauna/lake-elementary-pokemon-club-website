#!/usr/bin/env ruby

# Simple test to verify timezone changes work correctly
require_relative '../config/environment'

puts "🧪 Testing Timezone Changes in Email Notifications"
puts "=" * 60

# Test 1: Event timezone methods
puts "\n1. Testing Event timezone methods..."

event = Event.new(
  title: "Test Event",
  starts_at: Time.parse("2025-09-16 15:30:00 UTC"), # 3:30 PM UTC
  ends_at: Time.parse("2025-09-16 17:00:00 UTC"),   # 5:00 PM UTC
  time_zone: "America/Los_Angeles"                   # PST/PDT
)

puts "   Event starts_at (UTC): #{event.starts_at}"
puts "   Event timezone: #{event.time_zone}"
puts "   Event starts_at (local): #{event.event_datetime_in_timezone}"
puts "   Event ends_at (local): #{event.ends_at_in_timezone}"

# Verify the conversion is correct
expected_local = Time.parse("2025-09-16 08:30:00 -0700") # 8:30 AM PDT
actual_local = event.event_datetime_in_timezone

if actual_local.to_i == expected_local.to_i # Compare as timestamps
  puts "   ✅ Timezone conversion is correct"
else
  puts "   ❌ Timezone conversion failed"
  puts "      Expected: #{expected_local}"
  puts "      Actual: #{actual_local}"
end

# Test 2: Attendance timezone methods
puts "\n2. Testing Attendance timezone methods..."

attendance = Attendance.new(
  marked_at: Time.parse("2025-09-16 04:00:00 UTC"), # 4:00 AM UTC = 9:00 PM PDT (previous day)
  event: event
)

puts "   Attendance marked_at (UTC): #{attendance.marked_at}"
puts "   Attendance marked_at (event TZ): #{attendance.marked_at_in_event_timezone}"

# Verify the conversion is correct
expected_marked = Time.parse("2025-09-15 21:00:00 -0700") # 9:00 PM PDT previous day
actual_marked = attendance.marked_at_in_event_timezone

if actual_marked.to_i == expected_marked.to_i
  puts "   ✅ Attendance timezone conversion is correct"
else
  puts "   ❌ Attendance timezone conversion failed"
  puts "      Expected: #{expected_marked}"
  puts "      Actual: #{actual_marked}"
end

# Test 3: Email template rendering
puts "\n3. Testing email template rendering..."

begin
  user = User.new(
    first_name: "Test",
    last_name: "User",
    email_address: "test@example.com"
  )

  # Test new event email
  email = NotificationMailer.new_event(user, event)

  # Check if the email body contains timezone information
  email_body = email.body.to_s

  if email_body.include?("08:30 AM") && email_body.include?("PDT")
    puts "   ✅ New event email shows correct timezone"
  else
    puts "   ❌ New event email timezone incorrect"
    puts "      Looking for '08:30 AM' and 'PDT' in email body"
  end

  # Test attendance email
  student = Student.new(first_name: "Test", last_name: "Student")
  attendance_email = NotificationMailer.student_attendance_updated(user, student, event, attendance)

  attendance_body = attendance_email.body.to_s

  if attendance_body.include?("Tuesday, September 16, 2025") && attendance_body.include?("PDT")
    puts "   ✅ Attendance email shows correct timezone"
  else
    puts "   ❌ Attendance email timezone incorrect"
    puts "      Looking for 'Tuesday, September 16, 2025' and 'PDT' in email body"
  end

rescue => e
  puts "   ❌ Error testing email templates: #{e.message}"
end

puts "\n" + "=" * 60
puts "🧪 Timezone test completed"
