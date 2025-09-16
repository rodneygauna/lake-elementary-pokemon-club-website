#!/usr/bin/env ruby

# Test script for user profile update notifications
require_relative '../config/environment'

puts "🧪 Testing User Profile Update Notifications"
puts "=" * 50

begin
  # Create a test user
  user = User.create!(
    first_name: 'Test',
    last_name: 'User',
    email_address: 'test-profile@example.com',
    password: 'password123',
    role: 'user',
    status: 'active'
  )

  # Manually create the subscription (since this is a new user after migration)
  user.email_subscriptions.create!(subscription_type: 'user_profile_updated', enabled: true)

  puts "✅ Created test user: #{user.first_name} #{user.last_name}"
  puts "   Email: #{user.email_address}"
  puts "   Subscribed to user_profile_updated: #{user.subscribed_to?(:user_profile_updated)}"

  # Test 1: Basic profile update
  puts "\n1. Testing basic profile update..."

  user.update!(
    first_name: 'Updated',
    phone_number: '555-123-4567'
  )

  puts "   ✅ Profile updated successfully"
  puts "   Changed fields: #{user.saved_changes.keys}"

  # Test 2: Email generation
  puts "\n2. Testing email generation..."

  email = NotificationMailer.user_profile_updated(
    user,
    [ 'first_name', 'email_address', 'password_digest' ],
    false,
    nil
  )

  puts "   ✅ Email generated successfully"
  puts "   Subject: #{email.subject}"
  puts "   To: #{email.to.join(', ')}"

  # Test email content
  text_part = email.parts.find { |part| part.content_type.include?('text/plain') }
  if text_part && text_part.body.to_s.include?('Password')
    puts "   ✅ Email contains password change notification"
  else
    puts "   ❌ Email missing password change notification"
  end

  # Test 3: Admin email generation
  puts "\n3. Testing admin email generation..."

  admin = User.create!(
    first_name: 'Admin',
    last_name: 'User',
    email_address: 'admin-test@example.com',
    password: 'password123',
    role: 'admin',
    status: 'active'
  )

  admin_email = NotificationMailer.user_profile_updated(
    user,
    [ 'role', 'status' ],
    true,
    admin
  )

  puts "   ✅ Admin email generated successfully"
  puts "   Subject: #{admin_email.subject}"

  # Test admin email content
  admin_text_part = admin_email.parts.find { |part| part.content_type.include?('text/plain') }
  if admin_text_part && admin_text_part.body.to_s.include?('administrator')
    puts "   ✅ Email contains admin notification text"
  else
    puts "   ❌ Email missing admin notification text"
  end

  # Clean up
  user.destroy
  admin.destroy
  puts "\n✅ Test data cleaned up"

rescue => e
  puts "\n❌ Error: #{e.message}"
  puts e.backtrace.first(5).join("\n")

  # Clean up on error
  User.where(email_address: [ 'test-profile@example.com', 'admin-test@example.com' ]).destroy_all
end

puts "\n" + "=" * 50
puts "🧪 User profile notification test completed"
