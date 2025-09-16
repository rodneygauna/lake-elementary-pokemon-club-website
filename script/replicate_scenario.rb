#!/usr/bin/env ruby

# Replicate the exact scenario: student with 2 parents, adding a 3rd
require_relative '../config/environment'

puts "🎯 Replicating Your Exact Scenario"
puts "=" * 50

# Let's use Ava Anderson who already has multiple parents
student = Student.find_by(first_name: "Ava", last_name: "Anderson")
current_parents = student.users.includes(:email_subscriptions)

puts "📋 Current Setup:"
puts "   Student: #{student.first_name} #{student.last_name}"
puts "   Current parents (#{current_parents.count}):"
current_parents.each_with_index do |parent, index|
  subscription = parent.email_subscriptions.find_by(subscription_type: 'new_parent_linked')
  puts "     #{index + 1}. #{parent.first_name} #{parent.last_name} (#{parent.email_address})"
  puts "        Status: #{parent.status}, Role: #{parent.role}"
  puts "        Subscription enabled: #{subscription&.enabled || 'NO SUBSCRIPTION'}"
end

# Let's add a new parent who isn't already linked
new_parent = User.find_by(email_address: "lisa.martinez@email.com")
unless new_parent.students.include?(student)
  puts "\n📎 Adding new parent: #{new_parent.first_name} #{new_parent.last_name}"

  # Check their subscription status
  new_parent_subscription = new_parent.email_subscriptions.find_by(subscription_type: 'new_parent_linked')
  puts "   New parent subscription enabled: #{new_parent_subscription&.enabled || 'NO SUBSCRIPTION'}"

  puts "\n🔍 Before linking - testing notification logic:"

  # Test the exact query that will be used
  existing_parents = student.users.joins(:email_subscriptions)
                            .where(email_subscriptions: { subscription_type: :new_parent_linked, enabled: true })
                            .where(status: "active")
                            .where.not(id: new_parent.id)

  puts "   Parents who should receive notification (#{existing_parents.count}):"
  existing_parents.each do |parent|
    puts "     - #{parent.first_name} #{parent.last_name} (#{parent.email_address})"
  end

  # Manually test sending notifications
  puts "\n📧 Testing manual notification delivery:"
  existing_parents.each do |existing_parent|
    begin
      email = NotificationMailer.new_parent_linked(existing_parent, student, new_parent)
      puts "   ✅ Email prepared for #{existing_parent.first_name} #{existing_parent.last_name}"
      puts "      To: #{email.to.join(', ')}"
      puts "      Subject: #{email.subject}"

      # Actually deliver the email for testing
      email.deliver_now
      puts "      📮 Email delivered successfully"
    rescue => e
      puts "   ❌ Error sending to #{existing_parent.first_name}: #{e.message}"
    end
  end

  # Now create the actual link (this will trigger the callback)
  puts "\n🔗 Creating UserStudent link (triggers callback)..."
  user_student = UserStudent.create!(user: new_parent, student: student)
  puts "   ✅ UserStudent created successfully"
  puts "   📬 Callbacks should have been triggered:"
  puts "      - student_linked notification to #{new_parent.first_name}"
  puts "      - new_parent_linked notifications to #{existing_parents.count} existing parents"

  # Clean up the test
  user_student.destroy
  puts "\n🧹 Test link removed"

else
  puts "\n⚠️  #{new_parent.first_name} is already linked to #{student.first_name}"
  puts "   Let's test with someone else..."

  # Find a user who isn't linked to this student
  available_parent = User.joins("LEFT JOIN user_students ON user_students.user_id = users.id AND user_students.student_id = #{student.id}")
                         .where("user_students.id IS NULL")
                         .where(status: "active")
                         .where.not(role: "admin")
                         .first

  if available_parent
    puts "   Using #{available_parent.first_name} #{available_parent.last_name} instead"
    # Repeat the test with this parent
    # [Similar logic as above...]
  else
    puts "   No available parents to test with"
  end
end

puts "\n💡 Debugging Tips:"
puts "   1. Check Rails logs for any errors: tail -f log/development.log"
puts "   2. Verify ActionMailer configuration in config/environments/development.rb"
puts "   3. Check if background jobs are processing: background job queue status"
puts "   4. Look for delivery method settings (file, smtp, etc.)"
