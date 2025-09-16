#!/usr/bin/env ruby

# Debug script for parent unlinking notifications
require_relative '../config/environment'

puts "🔍 Debugging Parent Unlinking Notifications"
puts "=" * 50

# Find existing test data
parent1 = User.find_by(email_address: "parent1@test.com")
parent2 = User.find_by(email_address: "parent2@test.com")
parent3 = User.find_by(email_address: "parent3@test.com")
student = Student.find_by(first_name: "TestChild")

if [ parent1, parent2, parent3, student ].any?(&:nil?)
  puts "❌ Test data not found. Please run test_unlink_notifications.rb first."
  exit 1
end

puts "✅ Found test data"

# Test 1: Check if subscriptions exist
puts "\n🔍 Checking email subscriptions..."
[ parent1, parent2, parent3 ].each do |parent|
  unlinked_sub = parent.email_subscriptions.find_by(subscription_type: 'student_unlinked')
  parent_unlinked_sub = parent.email_subscriptions.find_by(subscription_type: 'parent_unlinked')

  puts "   #{parent.full_name}:"
  puts "     - student_unlinked: #{unlinked_sub&.enabled ? '✅ enabled' : '❌ missing/disabled'}"
  puts "     - parent_unlinked: #{parent_unlinked_sub&.enabled ? '✅ enabled' : '❌ missing/disabled'}"
end

# Test 2: Test individual mailer methods
puts "\n🔍 Testing individual mailer methods..."

# Test student_unlinked mailer
puts "\n   Testing student_unlinked mailer..."
begin
  email1 = NotificationMailer.student_unlinked(parent2, student)
  email1.deliver_now
  puts "   ✅ student_unlinked email sent to #{parent2.email_address}"
rescue => e
  puts "   ❌ student_unlinked failed: #{e.message}"
end

# Test parent_unlinked mailer
puts "\n   Testing parent_unlinked mailer..."
begin
  email2 = NotificationMailer.parent_unlinked(parent1, student, parent2)
  email2.deliver_now
  puts "   ✅ parent_unlinked email sent to #{parent1.email_address}"
rescue => e
  puts "   ❌ parent_unlinked failed: #{e.message}"
end

# Test 3: Test bulk notification methods
puts "\n🔍 Testing bulk notification methods..."

# Test send_student_unlinked_notification
puts "\n   Testing send_student_unlinked_notification..."
begin
  NotificationMailer.send_student_unlinked_notification(parent2, student)
  puts "   ✅ send_student_unlinked_notification completed"
rescue => e
  puts "   ❌ send_student_unlinked_notification failed: #{e.message}"
end

# Test send_parent_unlinked_notifications
puts "\n   Testing send_parent_unlinked_notifications..."
begin
  NotificationMailer.send_parent_unlinked_notifications(student, parent2)
  puts "   ✅ send_parent_unlinked_notifications completed"
rescue => e
  puts "   ❌ send_parent_unlinked_notifications failed: #{e.message}"
end

# Test 4: Test NotificationJob
puts "\n🔍 Testing NotificationJob..."

# Test student_unlinked job
puts "\n   Testing student_unlinked job..."
begin
  NotificationJob.perform_now("student_unlinked", parent2.id, student.id)
  puts "   ✅ student_unlinked job completed"
rescue => e
  puts "   ❌ student_unlinked job failed: #{e.message}"
end

# Test parent_unlinked job
puts "\n   Testing parent_unlinked job..."
begin
  NotificationJob.perform_now("parent_unlinked", student.id, parent2.id)
  puts "   ✅ parent_unlinked job completed"
rescue => e
  puts "   ❌ parent_unlinked job failed: #{e.message}"
end

# Check email count
emails_sent = ActionMailer::Base.deliveries.size
puts "\n📧 Total emails in test: #{emails_sent}"

puts "\n" + "=" * 50
puts "🔍 Debug completed"
