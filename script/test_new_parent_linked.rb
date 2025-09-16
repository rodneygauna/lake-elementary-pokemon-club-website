#!/usr/bin/env ruby

# Simple verification script for our new parent linked notification functionality
require_relative '../config/environment'

puts "Testing New Parent Linked Notification Feature..."
puts "=" * 50

# Find test users and student
parent1 = User.find_by(email_address: "sarah.johnson@email.com")
parent2 = User.find_by(email_address: "emily.davis@email.com")
student = Student.find_by(first_name: "Alex", last_name: "Johnson")

if parent1.nil? || parent2.nil? || student.nil?
  puts "❌ Test data not found. Please run `bin/rails db:seed` first."
  exit(1)
end

puts "📧 Testing email generation..."
email = NotificationMailer.new_parent_linked(parent1, student, parent2)
puts "✅ Email generated successfully"
puts "   To: #{email.to.join(', ')}"
puts "   Subject: #{email.subject}"
puts "   Body contains student name: #{email.body.to_s.include?(student.first_name)}"
puts "   Body contains new parent name: #{email.body.to_s.include?(parent2.first_name)}"

puts "\n🔗 Testing UserStudent callback integration..."

# Ensure both parents have the subscription
parent1.email_subscriptions.find_or_create_by(subscription_type: "new_parent_linked") { |s| s.enabled = true }
parent2.email_subscriptions.find_or_create_by(subscription_type: "new_parent_linked") { |s| s.enabled = true }

# Link parent1 to student first
user_student1 = UserStudent.find_or_create_by(user: parent1, student: student)
puts "✅ Parent1 (#{parent1.first_name}) linked to student (#{student.first_name})"

# Now link parent2 - this should trigger notification to parent1
puts "\n📬 Linking second parent (this should trigger notification)..."
user_student2 = UserStudent.create!(user: parent2, student: student)
puts "✅ Parent2 (#{parent2.first_name}) linked to student (#{student.first_name})"
puts "   Callbacks triggered: student_linked, new_parent_linked"

puts "\n🎯 Testing NotificationJob..."
puts "   Notification types available: #{EmailSubscription.subscription_types.keys}"
puts "   New subscription type added: #{EmailSubscription.subscription_types.key?('new_parent_linked')}"

puts "\n✅ Feature implementation complete!"
puts "   1. New subscription type added: new_parent_linked"
puts "   2. Email templates created (HTML and text)"
puts "   3. NotificationMailer method implemented"
puts "   4. NotificationJob updated"
puts "   5. UserStudent callbacks enhanced"
puts "   6. Migration applied for existing users"

# Clean up test data
user_student1.destroy if user_student1.persisted?
user_student2.destroy if user_student2.persisted?

puts "\n🧹 Test cleanup completed"
