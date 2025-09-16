#!/usr/bin/env ruby

# Test script for parent unlinking notifications
require_relative '../config/environment'

puts "🧪 Testing Parent Unlinking Notifications System"
puts "=" * 50

# Find or create test users and student
puts "\n📝 Setting up test data..."

# Create three parent users
parent1 = User.find_or_create_by(email_address: "parent1@test.com") do |user|
  user.first_name = "Alice"
  user.last_name = "Johnson"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = "user"
  user.status = "active"
end

parent2 = User.find_or_create_by(email_address: "parent2@test.com") do |user|
  user.first_name = "Bob"
  user.last_name = "Smith"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = "user"
  user.status = "active"
end

parent3 = User.find_or_create_by(email_address: "parent3@test.com") do |user|
  user.first_name = "Carol"
  user.last_name = "Williams"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = "user"
  user.status = "active"
end

# Create test student
student = Student.find_or_create_by(first_name: "TestChild", last_name: "Student") do |s|
  s.grade = "third_grade"
  s.status = "active"
end

puts "✅ Created test users:"
puts "   - Parent 1: #{parent1.full_name} (#{parent1.email_address})"
puts "   - Parent 2: #{parent2.full_name} (#{parent2.email_address})"
puts "   - Parent 3: #{parent3.full_name} (#{parent3.email_address})"
puts "   - Student: #{student.full_name}"

# Ensure all parents have the required subscriptions
puts "\n📧 Setting up email subscriptions..."
[ parent1, parent2, parent3 ].each do |parent|
  parent.create_default_subscriptions!

  # Specifically ensure they have both subscription types
  %w[student_unlinked parent_unlinked].each do |sub_type|
    parent.email_subscriptions.find_or_create_by(subscription_type: sub_type) do |subscription|
      subscription.enabled = true
    end
  end
end

puts "✅ Email subscriptions configured for all parents"

# Link all three parents to the student
puts "\n🔗 Linking all parents to student..."
[ parent1, parent2, parent3 ].each do |parent|
  unless UserStudent.exists?(user: parent, student: student)
    user_student = UserStudent.create!(user: parent, student: student)
    puts "   - Linked #{parent.full_name} to #{student.full_name}"
  else
    puts "   - #{parent.full_name} already linked to #{student.full_name}"
  end
end

# Verify initial setup
linked_parents = student.users.reload
puts "\n✅ Initial setup complete:"
puts "   - Student has #{linked_parents.count} linked parents"
linked_parents.each do |parent|
  puts "     * #{parent.full_name}"
end

# Test the unlink notification system
puts "\n🧪 Testing unlink notifications..."
puts "   Unlinking Parent 2 (#{parent2.full_name}) from student..."

# Clear any previous emails and capture emails sent during this test
ActionMailer::Base.deliveries.clear
emails_before = ActionMailer::Base.deliveries.size

# Unlink parent2 from student (this should trigger both notifications)
user_student_to_remove = UserStudent.find_by(user: parent2, student: student)
if user_student_to_remove
  user_student_to_remove.destroy!
  puts "✅ Parent 2 unlinked successfully"
else
  puts "❌ UserStudent relationship not found"
  exit 1
end

# Allow a moment for email processing
sleep(1)

emails_after = ActionMailer::Base.deliveries.size
new_emails = emails_after - emails_before

puts "\n📧 Email Results:"
puts "   - Emails sent: #{new_emails}"

if new_emails > 0
  # Show details of sent emails
  recent_emails = ActionMailer::Base.deliveries.last(new_emails)

  recent_emails.each_with_index do |email, index|
    puts "\n   📧 Email #{index + 1}:"
    puts "      To: #{email.to.first}"
    puts "      Subject: #{email.subject}"

    # Try to identify the recipient
    recipient = [ parent1, parent2, parent3 ].find { |p| p.email_address == email.to.first }
    if recipient
      puts "      Recipient: #{recipient.full_name}"
      if recipient == parent2
        puts "      Type: Student Unlinked (notification to removed parent)"
      else
        puts "      Type: Parent Unlinked (notification to remaining parent)"
      end
    end
  end
else
  puts "   ❌ No emails were sent"
end

# Verify final state
remaining_parents = student.users.reload
puts "\n✅ Final verification:"
puts "   - Student now has #{remaining_parents.count} linked parents"
remaining_parents.each do |parent|
  puts "     * #{parent.full_name}"
end

# Expected results
puts "\n🎯 Expected Results:"
puts "   - 3 emails should be sent:"
puts "     * 1 to Parent 2 (unlinked parent) - 'Student Removed from Your Account'"
puts "     * 1 to Parent 1 (remaining parent) - 'Parent Removed from Student Account'"
puts "     * 1 to Parent 3 (remaining parent) - 'Parent Removed from Student Account'"

if new_emails == 3
  puts "\n🎉 SUCCESS: All expected notifications sent!"
elsif new_emails == 1
  puts "\n⚠️  PARTIAL: Only unlinked parent notified (missing remaining parent notifications)"
else
  puts "\n❌ FAILURE: Unexpected number of emails sent"
end

puts "\n" + "=" * 50
puts "🧪 Test completed"
