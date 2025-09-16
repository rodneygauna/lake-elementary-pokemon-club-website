#!/usr/bin/env ruby

# Debug the query used in attendance notifications
require_relative '../config/environment'

puts "🔍 Debugging Attendance Query"
puts "=" * 35

# Find test data
parent = User.find_by(email_address: "attendance_parent@test.com")
student = Student.find_by(first_name: "AttendanceTest")

if [ parent, student ].any?(&:nil?)
  puts "❌ Test data not found"
  exit 1
end

puts "✅ Found test data"
puts "   Parent: #{parent.full_name} (ID: #{parent.id})"
puts "   Student: #{student.full_name} (ID: #{student.id})"

# Test the query used in the bulk notification method
puts "\n🔍 Testing the notification query..."

# This is the exact query from the mailer
users_query = student.users.joins(:email_subscriptions)
                     .where(email_subscriptions: { subscription_type: :student_attendance_updated, enabled: true })
                     .where(status: "active")

puts "   Query: student.users.joins(:email_subscriptions)"
puts "          .where(email_subscriptions: { subscription_type: :student_attendance_updated, enabled: true })"
puts "          .where(status: \"active\")"

users_found = users_query.to_a
puts "\n   Users found: #{users_found.size}"

if users_found.any?
  users_found.each do |user|
    puts "     - #{user.full_name} (#{user.email_address})"
  end
else
  puts "     No users found!"
end

# Debug step by step
puts "\n🔍 Step-by-step query debugging..."

# Step 1: Check if student has users
all_student_users = student.users.to_a
puts "   Step 1 - student.users: #{all_student_users.size} users"
all_student_users.each do |user|
  puts "     - #{user.full_name} (#{user.email_address}) - Status: #{user.status}"
end

# Step 2: Check email subscriptions
puts "\n   Step 2 - Email subscriptions for parent:"
parent_subscriptions = parent.email_subscriptions.to_a
parent_subscriptions.each do |sub|
  puts "     - #{sub.subscription_type}: #{sub.enabled ? 'enabled' : 'disabled'}"
end

# Step 3: Check the specific subscription
attendance_sub = parent.email_subscriptions.find_by(subscription_type: 'student_attendance_updated')
puts "\n   Step 3 - Attendance subscription:"
puts "     Exists: #{attendance_sub ? '✅' : '❌'}"
if attendance_sub
  puts "     Enabled: #{attendance_sub.enabled ? '✅' : '❌'}"
  puts "     ID: #{attendance_sub.id}"
end

# Step 4: Check user status
puts "\n   Step 4 - Parent status: #{parent.status}"

# Step 5: Test the join query manually
puts "\n   Step 5 - Manual join query:"
manual_query = User.joins(:email_subscriptions)
                   .where(email_subscriptions: { subscription_type: :student_attendance_updated, enabled: true })
                   .where(status: "active")
                   .where(id: parent.id)

manual_result = manual_query.to_a
puts "     Manual query result: #{manual_result.size} users"

# Step 6: Check if parent is linked to student
puts "\n   Step 6 - Parent-student link:"
user_student = UserStudent.find_by(user: parent, student: student)
puts "     Link exists: #{user_student ? '✅' : '❌'}"
if user_student
  puts "     Link ID: #{user_student.id}"
end

puts "\n" + "=" * 35
puts "🔍 Query debug completed"
