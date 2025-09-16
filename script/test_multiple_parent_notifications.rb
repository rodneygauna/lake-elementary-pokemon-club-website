#!/usr/bin/env ruby

# Test script to verify multiple parent notifications
require_relative '../config/environment'

puts "🧪 Testing Multiple Parent Attendance Notifications"
puts "=" * 60

# Find Olivia Brown and her parents
student = Student.find_by(first_name: 'Olivia', last_name: 'Brown')
if student.nil?
  puts "❌ Olivia Brown not found"
  exit 1
end

puts "✅ Found student: #{student.first_name} #{student.last_name}"

# Check linked parents
parents = student.users
puts "📋 Linked parents: #{parents.count}"
parents.each_with_index do |parent, index|
  puts "  #{index + 1}. #{parent.first_name} #{parent.last_name} (#{parent.email_address})"
  puts "     Status: #{parent.status}"

  # Check/enable subscription
  subscription = parent.email_subscriptions.find_or_create_by(subscription_type: 'student_attendance_updated')
  subscription.update!(enabled: true)

  puts "     Attendance subscription: #{subscription.enabled? ? 'ENABLED' : 'DISABLED'}"
  puts "     Subscribed to attendance: #{parent.subscribed_to?(:student_attendance_updated)}"
end

if parents.count < 2
  puts "❌ Need at least 2 parents for this test. Found: #{parents.count}"
  exit 1
end

# Find or create an event
event = Event.published.first
if event.nil?
  puts "❌ No published events found"
  exit 1
end

puts "\n📅 Using event: #{event.title}"

# Check current mail files
mail_dir = Rails.root.join('tmp', 'mails')
existing_files = Dir.glob(File.join(mail_dir, '*')).map { |f| File.basename(f) }
puts "\n📧 Mail files before test: #{existing_files.size}"

# Test the mailer query directly
puts "\n🔍 Testing mailer query..."
subscribed_parents = student.users.joins(:email_subscriptions)
                            .where(email_subscriptions: { subscription_type: :student_attendance_updated, enabled: true })
                            .where(status: "active")

puts "Query found #{subscribed_parents.count} subscribed parents:"
subscribed_parents.each do |parent|
  puts "  - #{parent.first_name} #{parent.last_name} (#{parent.email_address})"
end

# Create or update attendance record using the callback method
puts "\n📝 Creating attendance record (this should trigger notifications via callback)..."

attendance = Attendance.find_or_initialize_by(student: student, event: event)
attendance.assign_attributes(
  present: true,
  marked_by: User.first,
  marked_at: Time.current
)

puts "Saving attendance record..."
attendance.save!
puts "✅ Attendance saved successfully"

# Wait for file writes to complete
sleep(2)

# Check for new mail files
new_files = Dir.glob(File.join(mail_dir, '*')).map { |f| File.basename(f) }
new_files_created = new_files - existing_files

puts "\n📧 Results:"
puts "Expected emails: #{subscribed_parents.count}"
puts "Actual emails sent: #{new_files_created.size}"
puts "New mail files: #{new_files_created.join(', ')}"

if new_files_created.size == subscribed_parents.count
  puts "✅ SUCCESS: All parents received notifications!"
else
  puts "❌ FAILURE: Expected #{subscribed_parents.count} emails, got #{new_files_created.size}"

  # Show which parents got emails and which didn't
  expected_emails = subscribed_parents.map(&:email_address)
  puts "\nExpected email recipients:"
  expected_emails.each { |email| puts "  - #{email}" }

  puts "\nActual email recipients:"
  new_files_created.each { |email| puts "  - #{email}" }

  missing_emails = expected_emails - new_files_created
  if missing_emails.any?
    puts "\nMissing emails for:"
    missing_emails.each { |email| puts "  - #{email}" }
  end
end

# Test manual method call
puts "\n🔧 Testing manual notification method..."
puts "Calling NotificationMailer.send_student_attendance_notification directly..."

begin
  # Clear existing files first
  Dir.glob(File.join(mail_dir, '*')).each { |f| File.delete(f) }

  NotificationMailer.send_student_attendance_notification(student, event, attendance)

  sleep(1)

  manual_files = Dir.glob(File.join(mail_dir, '*')).map { |f| File.basename(f) }
  puts "Manual method sent #{manual_files.size} emails: #{manual_files.join(', ')}"

  if manual_files.size == subscribed_parents.count
    puts "✅ Manual method works correctly!"
  else
    puts "❌ Manual method also has issues"
  end
rescue => e
  puts "❌ Error in manual method: #{e.message}"
end

puts "\n" + "=" * 60
puts "🧪 Multiple parent notification test completed"
