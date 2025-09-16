#!/usr/bin/env ruby

# Generate a real email with timezone information
require_relative '../config/environment'

puts "📧 Generating test email with timezone information..."
puts "=" * 50

begin
  # Create test data
  event = Event.create!(
    title: 'Timezone Test Event',
    description: 'Testing timezone display in emails',
    starts_at: Time.parse('2025-09-16 15:30:00 UTC'),
    ends_at: Time.parse('2025-09-16 17:00:00 UTC'),
    time_zone: 'America/Los_Angeles',
    venue: 'Test Location',
    status: 'published'
  )

  user = User.create!(
    first_name: 'Test',
    last_name: 'User',
    email_address: 'test@example.com',
    password: 'password123',
    role: 'user'
  )

  puts "✅ Created test event and user"
  puts "   Event time (UTC): #{event.starts_at}"
  puts "   Event timezone: #{event.time_zone}"
  puts "   Event time (local): #{event.event_datetime_in_timezone}"

  # Generate and deliver the email
  email = NotificationMailer.new_event(user, event)
  email.deliver

  puts "✅ Email delivered to tmp/mails/"
  puts "   Check the generated files for timezone information"

  # Clean up
  event.destroy
  user.destroy
  puts "✅ Test data cleaned up"

rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(3).join("\n")
end

puts "=" * 50
puts "📧 Email generation test completed"
