#!/usr/bin/env ruby

# Test file delivery method
require_relative '../config/environment'

puts "📧 Testing File Delivery Method"
puts "=" * 35

# Find test data
parent = User.find_by(email_address: "attendance_parent@test.com")
student = Student.find_by(first_name: "AttendanceTest")
event = Event.find_by(title: "Test Event for Attendance")

if [ parent, student, event ].any?(&:nil?)
  puts "❌ Test data not found. Run attendance test first."
  exit 1
end

puts "✅ Found test data"

# Check current delivery method
puts "📧 ActionMailer configuration:"
puts "   Delivery method: #{ActionMailer::Base.delivery_method}"
puts "   Perform deliveries: #{ActionMailer::Base.perform_deliveries}"

# Clear any existing mail files
mail_dir = Rails.root.join('tmp', 'mails')
puts "\n📁 Mail directory: #{mail_dir}"

# Count existing files
existing_files = Dir.glob(File.join(mail_dir, "*")).size
puts "   Existing mail files: #{existing_files}"

# Send a test attendance notification
puts "\n📧 Sending test attendance notification..."

# Create or find attendance record
attendance = Attendance.find_or_initialize_by(student: student, event: event)
attendance.assign_attributes(
  present: true,
  marked_by: User.first,
  marked_at: Time.current
)

begin
  attendance.save!
  puts "   ✅ Attendance saved and notification triggered"
rescue => e
  puts "   ❌ Error: #{e.message}"
end

# Check for new mail files
sleep(1) # Give it a moment to write files

new_files_count = Dir.glob(File.join(mail_dir, "*")).size
new_files = new_files_count - existing_files

puts "\n📁 File delivery results:"
puts "   New mail files created: #{new_files}"

if new_files > 0
  # Show the latest mail file
  latest_file = Dir.glob(File.join(mail_dir, "*")).max_by { |f| File.mtime(f) }
  puts "   Latest mail file: #{File.basename(latest_file)}"

  puts "\n📧 Email content preview:"
  content = File.read(latest_file)

  # Extract key information
  if content.match(/To: (.+)/)
    puts "   To: #{$1}"
  end

  if content.match(/Subject: (.+)/)
    puts "   Subject: #{$1}"
  end

  puts "   File size: #{File.size(latest_file)} bytes"
  puts "   Full path: #{latest_file}"

  puts "\n   📖 To view the full email:"
  puts "   cat #{latest_file}"
else
  puts "   ❌ No mail files were created"
end

puts "\n" + "=" * 35
puts "📧 File delivery test completed"
