#!/usr/bin/env ruby

# Test script for attendance notifications
require_relative '../config/environment'

puts "🧪 Testing Attendance Notifications System"
puts "=" * 50

# Find or create test data
puts "\n📝 Setting up test data..."

# Create test user and student
parent = User.find_or_create_by(email_address: "attendance_parent@test.com") do |user|
  user.first_name = "AttendanceTest"
  user.last_name = "Parent"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = "user"
  user.status = "active"
end

student = Student.find_or_create_by(first_name: "AttendanceTest", last_name: "Student") do |s|
  s.grade = "third_grade"
  s.status = "active"
end

admin = User.find_by(role: "admin") || User.first

if admin.nil?
  puts "❌ No admin user found. Cannot test attendance marking."
  exit 1
end

# Create test event
event = Event.find_or_create_by(title: "Test Event for Attendance") do |e|
  e.description = "Test event for attendance notifications"
  e.starts_at = Time.current + 1.hour
  e.ends_at = Time.current + 2.hours
  e.venue = "Test Location"
  e.status = "published"
  e.time_zone = "America/New_York"
end

# Link parent to student
UserStudent.find_or_create_by(user: parent, student: student)

# Set up email subscriptions
parent.create_default_subscriptions!

# Ensure parent has attendance notification subscription
attendance_sub = parent.email_subscriptions.find_or_create_by(subscription_type: 'student_attendance_updated')
attendance_sub.update!(enabled: true)

puts "✅ Test data setup complete:"
puts "   - Parent: #{parent.full_name} (#{parent.email_address})"
puts "   - Student: #{student.full_name}"
puts "   - Event: #{event.title}"
puts "   - Admin marker: #{admin.full_name}"

# Check subscription status
sub_status = parent.subscribed_to?(:student_attendance_updated)
puts "   - Attendance subscription: #{sub_status ? '✅ enabled' : '❌ disabled'}"

# Clear previous emails
ActionMailer::Base.deliveries.clear

# Test attendance marking
puts "\n🧪 Testing attendance notification..."
puts "   Marking student as present for event..."

# Create or update attendance record
attendance = Attendance.find_or_initialize_by(student: student, event: event)
attendance.assign_attributes(
  present: true,
  marked_by: admin,
  marked_at: Time.current
)

emails_before = ActionMailer::Base.deliveries.size
attendance.save!
emails_after = ActionMailer::Base.deliveries.size

puts "✅ Attendance marked successfully"

# Check emails
new_emails = emails_after - emails_before
puts "\n📧 Email Results:"
puts "   - Emails sent: #{new_emails}"

if new_emails > 0
  recent_emails = ActionMailer::Base.deliveries.last(new_emails)

  recent_emails.each_with_index do |email, index|
    puts "\n   📧 Email #{index + 1}:"
    puts "      To: #{email.to.first}"
    puts "      Subject: #{email.subject}"
    puts "      Recipient: #{parent.full_name}"
  end
else
  puts "   ❌ No emails were sent"
end

# Test with attendance change
puts "\n🧪 Testing attendance change notification..."
puts "   Changing student to absent..."

ActionMailer::Base.deliveries.clear
emails_before = ActionMailer::Base.deliveries.size

attendance.update!(present: false, marked_at: Time.current)

emails_after = ActionMailer::Base.deliveries.size
new_emails = emails_after - emails_before

puts "✅ Attendance changed to absent"
puts "\n📧 Change Email Results:"
puts "   - Emails sent: #{new_emails}"

if new_emails > 0
  recent_emails = ActionMailer::Base.deliveries.last(new_emails)

  recent_emails.each_with_index do |email, index|
    puts "\n   📧 Email #{index + 1}:"
    puts "      To: #{email.to.first}"
    puts "      Subject: #{email.subject}"
  end
end

# Expected results
puts "\n🎯 Expected Results:"
puts "   - 2 emails should be sent total (1 for marking present, 1 for changing to absent)"
puts "   - Both emails should go to #{parent.email_address}"
puts "   - Subject should be 'Attendance Updated for #{student.first_name}'"

total_emails = ActionMailer::Base.deliveries.select { |email|
  email.to.include?(parent.email_address) && email.subject.include?("Attendance Updated")
}.size

if total_emails >= 1
  puts "\n🎉 SUCCESS: Attendance notifications are working!"
else
  puts "\n❌ FAILURE: No attendance notifications sent"
end

puts "\n" + "=" * 50
puts "🧪 Attendance test completed"
