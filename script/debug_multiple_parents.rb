#!/usr/bin/env ruby

# Debug script to test new parent linked notifications with multiple existing parents
require_relative '../config/environment'

puts "🔍 Debugging Multiple Parent Notification Issue"
puts "=" * 60

# Find a student with multiple parents or create a test scenario
student = Student.find_by(first_name: "Alex", last_name: "Johnson")
parent1 = User.find_by(email_address: "sarah.johnson@email.com")
parent2 = User.find_by(email_address: "mike.smith@email.com")
parent3 = User.find_by(email_address: "emily.davis@email.com")

if student.nil? || parent1.nil? || parent2.nil? || parent3.nil?
  puts "❌ Test data not found. Please ensure seed data is available."
  exit(1)
end

puts "📋 Test Setup:"
puts "   Student: #{student.first_name} #{student.last_name}"
puts "   Parent 1: #{parent1.first_name} #{parent1.last_name} (#{parent1.email_address})"
puts "   Parent 2: #{parent2.first_name} #{parent2.last_name} (#{parent2.email_address})"
puts "   Parent 3: #{parent3.first_name} #{parent3.last_name} (#{parent3.email_address})"

# Clean up any existing links
UserStudent.where(student: student).destroy_all
puts "\n🧹 Cleaned up existing student-parent links"

# Ensure all parents have the subscription enabled
[ parent1, parent2, parent3 ].each do |parent|
  subscription = parent.email_subscriptions.find_or_initialize_by(subscription_type: "new_parent_linked")
  subscription.enabled = true
  subscription.save!
  puts "✅ #{parent.first_name} subscription enabled: #{subscription.enabled}"
end

# Link Parent 1 to student
puts "\n📎 Step 1: Linking Parent 1 to student..."
UserStudent.create!(user: parent1, student: student)
puts "   Current parents for #{student.first_name}: #{student.users.pluck(:first_name, :last_name).map { |f, l| "#{f} #{l}" }.join(', ')}"

# Link Parent 2 to student
puts "\n📎 Step 2: Linking Parent 2 to student..."
UserStudent.create!(user: parent2, student: student)
current_parents = student.users.pluck(:first_name, :last_name).map { |f, l| "#{f} #{l}" }
puts "   Current parents for #{student.first_name}: #{current_parents.join(', ')}"

# Now test the notification logic when Parent 3 is added
puts "\n🔍 Step 3: Testing notification logic for Parent 3..."

puts "\n📧 Testing send_new_parent_linked_notifications directly:"
existing_parents = student.users.joins(:email_subscriptions)
                          .where(email_subscriptions: { subscription_type: :new_parent_linked, enabled: true })
                          .where(status: "active")
                          .where.not(id: parent3.id)

puts "   Query for existing parents (excluding Parent 3):"
puts "   SQL: #{existing_parents.to_sql}"
puts "   Found #{existing_parents.count} existing parents:"
existing_parents.each do |parent|
  puts "     - #{parent.first_name} #{parent.last_name} (#{parent.email_address})"
  puts "       Status: #{parent.status}"
  puts "       Has subscription: #{parent.email_subscriptions.where(subscription_type: 'new_parent_linked').exists?}"
  subscription = parent.email_subscriptions.find_by(subscription_type: 'new_parent_linked')
  puts "       Subscription enabled: #{subscription&.enabled}"
end

# Test the actual notification method
puts "\n📬 Testing actual notification delivery:"
begin
  NotificationMailer.send_new_parent_linked_notifications(student, parent3)
  puts "✅ Notification method executed successfully"
rescue => e
  puts "❌ Error in notification method: #{e.message}"
  puts "   Backtrace: #{e.backtrace.first(5).join("\n   ")}"
end

# Now actually link Parent 3 to trigger the callback
puts "\n📎 Step 4: Actually linking Parent 3 (triggers callback)..."
UserStudent.create!(user: parent3, student: student)
final_parents = student.users.pluck(:first_name, :last_name).map { |f, l| "#{f} #{l}" }
puts "   Final parents for #{student.first_name}: #{final_parents.join(', ')}"

puts "\n🎯 Summary:"
puts "   - Student has #{student.users.count} parents linked"
puts "   - When Parent 3 was added, #{existing_parents.count} existing parents should have been notified"
puts "   - Check your email logs or ActionMailer delivery to see if emails were sent"

# Clean up
UserStudent.where(student: student).destroy_all
puts "\n🧹 Cleanup completed"
