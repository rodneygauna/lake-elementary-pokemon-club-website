#!/usr/bin/env ruby

# Direct test of attendance mailer without error handling
require_relative '../config/environment'

puts "🔍 Direct Attendance Mailer Test"
puts "=" * 35

# Find test data
parent = User.find_by(email_address: "attendance_parent@test.com")
student = Student.find_by(first_name: "AttendanceTest")
event = Event.find_by(title: "Test Event for Attendance")
attendance = Attendance.find_by(student: student, event: event)

if [ parent, student, event, attendance ].any?(&:nil?)
  puts "❌ Test data not found"
  puts "   Parent: #{parent ? '✅' : '❌'}"
  puts "   Student: #{student ? '✅' : '❌'}"
  puts "   Event: #{event ? '✅' : '❌'}"
  puts "   Attendance: #{attendance ? '✅' : '❌'}"
  exit 1
end

puts "✅ Found all test data"

# Clear existing emails
ActionMailer::Base.deliveries.clear

# Test the mailer method directly without error handling
puts "\n🔍 Testing mailer method directly..."

begin
  puts "   Calling NotificationMailer.student_attendance_updated..."
  email = NotificationMailer.student_attendance_updated(parent, student, event, attendance)
  puts "   ✅ Email object created"
  puts "   Subject: #{email.subject}"
  puts "   To: #{email.to.first}"

  puts "   Calling deliver_now..."
  email.deliver_now
  puts "   ✅ Email delivered"
  puts "   Total emails in deliveries: #{ActionMailer::Base.deliveries.size}"

rescue => e
  puts "   ❌ Error: #{e.message}"
  puts "   Backtrace:"
  e.backtrace.first(5).each { |line| puts "     #{line}" }
end

# Test the bulk method by calling each step manually
puts "\n🔍 Testing bulk method manually..."
ActionMailer::Base.deliveries.clear

# Get the users manually
users = student.users.joins(:email_subscriptions)
               .where(email_subscriptions: { subscription_type: :student_attendance_updated, enabled: true })
               .where(status: "active")

puts "   Found #{users.count} users"

users.each do |user|
  puts "   Processing user: #{user.full_name}"

  begin
    email = NotificationMailer.student_attendance_updated(user, student, event, attendance)
    email.deliver_now
    puts "     ✅ Email sent to #{user.email_address}"
  rescue => e
    puts "     ❌ Error for #{user.email_address}: #{e.message}"
  end
end

puts "\n   Total emails sent: #{ActionMailer::Base.deliveries.size}"

puts "\n" + "=" * 35
puts "🔍 Direct test completed"
