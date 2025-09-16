#!/usr/bin/env ruby

# Debug attendance notifications
require_relative '../config/environment'

puts "🔍 Debugging Attendance Notifications"
puts "=" * 40

# Find existing test data
parent = User.find_by(email_address: "attendance_parent@test.com")
student = Student.find_by(first_name: "AttendanceTest")
event = Event.find_by(title: "Test Event for Attendance")

if [ parent, student, event ].any?(&:nil?)
  puts "❌ Test data not found. Please run test_attendance_notifications.rb first."
  exit 1
end

puts "✅ Found test data"

# Test 1: Check subscription
puts "\n🔍 Checking subscription..."
subscription = parent.email_subscriptions.find_by(subscription_type: 'student_attendance_updated')
puts "   Subscription exists: #{subscription ? '✅' : '❌'}"
puts "   Subscription enabled: #{subscription&.enabled ? '✅' : '❌'}"
puts "   User subscribed?: #{parent.subscribed_to?(:student_attendance_updated) ? '✅' : '❌'}"

# Test 2: Check mailer method directly
puts "\n🔍 Testing mailer method directly..."
ActionMailer::Base.deliveries.clear

begin
  email = NotificationMailer.student_attendance_updated(parent, student, event, nil)
  puts "   Mailer method callable: ✅"
  puts "   Email subject: #{email.subject}"

  email.deliver_now
  puts "   Email delivery: ✅"
  puts "   Emails in deliveries: #{ActionMailer::Base.deliveries.size}"
rescue => e
  puts "   ❌ Mailer method failed: #{e.message}"
end

# Test 3: Test the bulk notification method
puts "\n🔍 Testing bulk notification method..."
ActionMailer::Base.deliveries.clear

# Create a dummy attendance record for testing
dummy_attendance = Attendance.new(
  student: student,
  event: event,
  present: true,
  marked_by: User.first,
  marked_at: Time.current
)

begin
  NotificationMailer.send_student_attendance_notification(student, event, dummy_attendance)
  puts "   Bulk method callable: ✅"
  puts "   Emails sent: #{ActionMailer::Base.deliveries.size}"
rescue => e
  puts "   ❌ Bulk method failed: #{e.message}"
end

# Test 4: Check if attendance callback is being triggered
puts "\n🔍 Testing attendance save callback..."
ActionMailer::Base.deliveries.clear

# Check if there's an existing attendance record
existing_attendance = Attendance.find_by(student: student, event: event)
if existing_attendance
  puts "   Found existing attendance record"
  puts "   Current status: #{existing_attendance.present? ? 'present' : 'absent'}"

  # Try to trigger the callback by changing the attendance
  puts "   Changing attendance status..."
  original_status = existing_attendance.present
  new_status = !original_status

  existing_attendance.update!(present: new_status, marked_at: Time.current)
  puts "   Attendance updated: #{original_status} → #{new_status}"
  puts "   Emails after update: #{ActionMailer::Base.deliveries.size}"
else
  puts "   No existing attendance record found"
  puts "   Creating new attendance record..."

  new_attendance = Attendance.create!(
    student: student,
    event: event,
    present: true,
    marked_by: User.first,
    marked_at: Time.current
  )
  puts "   New attendance created"
  puts "   Emails after creation: #{ActionMailer::Base.deliveries.size}"
end

# Test 5: Check the method implementation
puts "\n🔍 Checking method implementation..."
attendance = Attendance.find_by(student: student, event: event)
if attendance
  puts "   Attendance record ID: #{attendance.id}"
  puts "   Student: #{attendance.student.full_name}"
  puts "   Event: #{attendance.event.title}"
  puts "   Present: #{attendance.present}"
  puts "   Marked by: #{attendance.marked_by.full_name}"

  # Try calling the notification method directly
  puts "\n   Calling send_attendance_notification directly..."
  ActionMailer::Base.deliveries.clear

  begin
    attendance.send_attendance_notification
    puts "   Method called successfully"
    puts "   Emails sent: #{ActionMailer::Base.deliveries.size}"
  rescue => e
    puts "   ❌ Method failed: #{e.message}"
    puts "   Backtrace: #{e.backtrace.first(3).join("\n   ")}"
  end
end

puts "\n" + "=" * 40
puts "🔍 Debug completed"
