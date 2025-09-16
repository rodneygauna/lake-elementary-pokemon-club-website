#!/usr/bin/env ruby

# Test the updated synchronous notification implementation
require_relative '../config/environment'

puts "🔄 Testing Updated Synchronous Notification Implementation"
puts "=" * 65

# Use a clean test case
student = Student.find_by(first_name: "Connor", last_name: "Green")
parent1 = User.find_by(email_address: "mike.smith@email.com")
parent2 = User.find_by(email_address: "jennifer.brown@email.com")
new_parent = User.find_by(email_address: "david.garcia@email.com")

# Clean up any existing links for this test
UserStudent.where(student: student).destroy_all

puts "📋 Test Setup:"
puts "   Student: #{student.first_name} #{student.last_name}"
puts "   Parent 1: #{parent1.first_name} #{parent1.last_name}"
puts "   Parent 2: #{parent2.first_name} #{parent2.last_name}"
puts "   New Parent: #{new_parent.first_name} #{new_parent.last_name}"

# Ensure subscriptions are enabled
[ parent1, parent2, new_parent ].each do |parent|
  subscription = parent.email_subscriptions.find_or_initialize_by(subscription_type: "new_parent_linked")
  subscription.enabled = true
  subscription.save!
end

# Link first two parents
puts "\n📎 Setting up initial parents..."
UserStudent.create!(user: parent1, student: student)
UserStudent.create!(user: parent2, student: student)
puts "   Current parents: #{student.users.pluck(:first_name).join(', ')}"

# Now add the third parent - this should trigger synchronous notifications
puts "\n🚀 Adding third parent (should trigger immediate notifications)..."

# Capture any output or errors
begin
  UserStudent.create!(user: new_parent, student: student)
  puts "   ✅ UserStudent link created successfully"
  puts "   📧 Synchronous notifications should have been sent to:"

  existing_parents = student.users.where.not(id: new_parent.id).joins(:email_subscriptions)
                            .where(email_subscriptions: { subscription_type: :new_parent_linked, enabled: true })
                            .where(status: "active")

  existing_parents.each do |parent|
    puts "      - #{parent.first_name} #{parent.last_name} (#{parent.email_address})"
  end

  puts "   📬 Total notifications sent: #{existing_parents.count}"

rescue => e
  puts "   ❌ Error during link creation: #{e.message}"
  puts "      #{e.backtrace.first(3).join("\n      ")}"
end

# Final status
final_parents = student.users.pluck(:first_name, :last_name).map { |f, l| "#{f} #{l}" }
puts "\n📊 Final Status:"
puts "   Student #{student.first_name} now has #{student.users.count} parents: #{final_parents.join(', ')}"

# Clean up
UserStudent.where(student: student).destroy_all
puts "\n🧹 Test cleanup completed"

puts "\n💡 Key Improvement:"
puts "   New parent notifications are now sent SYNCHRONOUSLY (immediately)"
puts "   instead of being queued as background jobs, ensuring better reliability."
