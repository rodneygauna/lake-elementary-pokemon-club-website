#!/usr/bin/env ruby

# Test script to verify timezone changes in email notifications
require_relative '../config/environment'

puts "🧪 Testing Timezone Changes in Email Notifications"
puts "=" * 60

# Create a test event in UTC
event = Event.new(
  title: 'Test Event',
  starts_at: Time.parse('2025-09-16 15:30:00 UTC'),
  ends_at: Time.parse('2025-09-16 17:00:00 UTC'),
  time_zone: 'America/Los_Angeles'
)

student = Student.new(
  first_name: 'Test',
  last_name: 'Student',
  grade: 'third_grade'
)

attendance = Attendance.new(
  student: student,
  event: event,
  present: true,
  marked_at: Time.parse('2025-09-16 04:00:00 UTC')
)

user = User.new(
  first_name: 'Test',
  last_name: 'User',
  email_address: 'test@example.com'
)

# Test 1: Event timezone methods
puts "\n1. Testing Event timezone methods..."
puts "   Event starts_at (UTC): #{event.starts_at}"
puts "   Event timezone: #{event.time_zone}"
datetime_result = event.event_datetime_in_timezone
puts "   Event starts_at (formatted): #{datetime_result}"

if datetime_result.include?('8:30 AM') && datetime_result.include?('PDT')
  puts "   ✅ Timezone conversion is correct"
else
  puts "   ❌ Timezone conversion failed"
  puts "      Expected: Contains '8:30 AM' and 'PDT'"
  puts "      Actual: #{datetime_result}"
end

# Test 2: Attendance timezone methods
puts "\n2. Testing Attendance timezone methods..."
puts "   Attendance marked_at (UTC): #{attendance.marked_at}"
marked_result = attendance.marked_at_in_event_timezone
puts "   Attendance marked_at (formatted): #{marked_result}"

if marked_result.include?('9:00 PM') && marked_result.include?('PDT')
  puts "   ✅ Attendance timezone conversion is correct"
else
  puts "   ❌ Attendance timezone conversion failed"
  puts "      Expected: Contains '9:00 PM' and 'PDT'"
  puts "      Actual: #{marked_result}"
end

# Test 3: Email template rendering
puts "\n3. Testing email template rendering..."

begin
  # Test new event email
  new_event_email = NotificationMailer.new_event(user, event)
  text_part = new_event_email.parts.find { |part| part.content_type.include?('text/plain') }
  html_part = new_event_email.parts.find { |part| part.content_type.include?('text/html') }

  text_body = text_part ? text_part.body.to_s : ''
  html_body = html_part ? html_part.body.to_s : ''

  if (text_body.include?('8:30 AM') && text_body.include?('PDT')) ||
     (html_body.include?('8:30 AM') && html_body.include?('PDT'))
    puts "   ✅ New event email timezone correct"
  else
    puts "   ❌ New event email timezone incorrect"
    puts "      Looking for '8:30 AM' and 'PDT' in email body"
    puts "      Text has '8:30 AM': #{text_body.include?('8:30 AM')}"
    puts "      Text has 'PDT': #{text_body.include?('PDT')}"
    puts "      HTML has '8:30 AM': #{html_body.include?('8:30 AM')}"
    puts "      HTML has 'PDT': #{html_body.include?('PDT')}"
  end

  # Test attendance email
  attendance_email = NotificationMailer.student_attendance_updated(user, student, event, attendance)
  text_part = attendance_email.parts.find { |part| part.content_type.include?('text/plain') }
  html_part = attendance_email.parts.find { |part| part.content_type.include?('text/html') }

  text_body = text_part ? text_part.body.to_s : ''
  html_body = html_part ? html_part.body.to_s : ''

  if (text_body.include?('Tuesday, September 16, 2025') && text_body.include?('PDT')) ||
     (html_body.include?('Tuesday, September 16, 2025') && html_body.include?('PDT'))
    puts "   ✅ Attendance email timezone correct"
  else
    puts "   ❌ Attendance email timezone incorrect"
    puts "      Looking for 'Tuesday, September 16, 2025' and 'PDT' in email body"
    puts "      Text has date: #{text_body.include?('Tuesday, September 16, 2025')}"
    puts "      Text has 'PDT': #{text_body.include?('PDT')}"
    puts "      HTML has date: #{html_body.include?('Tuesday, September 16, 2025')}"
    puts "      HTML has 'PDT': #{html_body.include?('PDT')}"
  end

rescue => e
  puts "   ❌ Email rendering failed: #{e.message}"
  puts "      #{e.backtrace.first}"
end

puts "\n" + "=" * 60
puts "🧪 Timezone test completed"
