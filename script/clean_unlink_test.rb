#!/usr/bin/env ruby

# Clean test script for parent unlinking notifications
require_relative '../config/environment'

puts "🧪 Clean Parent Unlinking Notifications Test"
puts "=" * 50

# Clean up any existing test data
puts "\n🧹 Cleaning up existing test data..."
User.where(email_address: [ "parent1_clean@test.com", "parent2_clean@test.com", "parent3_clean@test.com" ]).destroy_all
Student.where(first_name: "CleanTestChild").destroy_all

# Create fresh test users
puts "\n📝 Creating fresh test data..."

parent1 = User.create!(
  email_address: "parent1_clean@test.com",
  first_name: "Alice",
  last_name: "Johnson",
  password: "password123",
  password_confirmation: "password123",
  role: "user",
  status: "active"
)

parent2 = User.create!(
  email_address: "parent2_clean@test.com",
  first_name: "Bob",
  last_name: "Smith",
  password: "password123",
  password_confirmation: "password123",
  role: "user",
  status: "active"
)

parent3 = User.create!(
  email_address: "parent3_clean@test.com",
  first_name: "Carol",
  last_name: "Williams",
  password: "password123",
  password_confirmation: "password123",
  role: "user",
  status: "active"
)

student = Student.create!(
  first_name: "CleanTestChild",
  last_name: "Student",
  grade: "third_grade",
  status: "active"
)

puts "✅ Created fresh test data"

# Set up email subscriptions
puts "\n📧 Setting up email subscriptions..."
[ parent1, parent2, parent3 ].each do |parent|
  parent.create_default_subscriptions!
end
puts "✅ Email subscriptions configured"

# Clear any emails from user creation
ActionMailer::Base.deliveries.clear

# Link all parents to student
puts "\n🔗 Linking all parents to student..."
UserStudent.create!(user: parent1, student: student)
UserStudent.create!(user: parent2, student: student)
UserStudent.create!(user: parent3, student: student)

# Clear linking notification emails
ActionMailer::Base.deliveries.clear
puts "✅ All parents linked (cleared linking notifications)"

# Verify setup
linked_parents = student.users.reload
puts "\n✅ Setup complete - Student has #{linked_parents.count} linked parents:"
linked_parents.each { |parent| puts "     * #{parent.full_name}" }

# Test unlinking
puts "\n🧪 Testing unlink notifications..."
puts "   Unlinking Parent 2 (#{parent2.full_name}) from student..."

# Find and destroy the user-student relationship
user_student_to_remove = UserStudent.find_by(user: parent2, student: student)
user_student_to_remove.destroy!
puts "✅ Parent 2 unlinked successfully"

# Check emails
emails_sent = ActionMailer::Base.deliveries.size
puts "\n📧 Email Results:"
puts "   - Emails sent: #{emails_sent}"

if emails_sent > 0
  ActionMailer::Base.deliveries.each_with_index do |email, index|
    puts "\n   📧 Email #{index + 1}:"
    puts "      To: #{email.to.first}"
    puts "      Subject: #{email.subject}"

    recipient = [ parent1, parent2, parent3 ].find { |p| p.email_address == email.to.first }
    if recipient
      puts "      Recipient: #{recipient.full_name}"
      if recipient == parent2
        puts "      Type: ✅ Student Unlinked (notification to removed parent)"
      else
        puts "      Type: ✅ Parent Unlinked (notification to remaining parent)"
      end
    end
  end
end

# Verify final state
remaining_parents = student.users.reload
puts "\n✅ Final verification:"
puts "   - Student now has #{remaining_parents.count} linked parents"
remaining_parents.each { |parent| puts "     * #{parent.full_name}" }

# Results
puts "\n🎯 Expected: 3 emails total"
puts "   - 1 to unlinked parent (Bob Smith)"
puts "   - 2 to remaining parents (Alice Johnson, Carol Williams)"

if emails_sent == 3
  puts "\n🎉 SUCCESS: Correct number of notifications sent!"
else
  puts "\n❌ FAILURE: Expected 3 emails, got #{emails_sent}"
end

puts "\n" + "=" * 50
puts "🧪 Clean test completed"
