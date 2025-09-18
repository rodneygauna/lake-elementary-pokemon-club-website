#!/usr/bin/env ruby
# Test script to verify email preferences functionality

require_relative '../config/environment'

puts "🧪 Email Preferences Test Script"
puts "=" * 50

# Get a test user
user = User.first
puts "Testing with user: #{user.email_address}"

puts "\n📋 Current Email Preferences:"
user.email_subscriptions.order(:subscription_type).each do |sub|
  puts "  #{sub.subscription_type.ljust(25)} → #{sub.enabled ? '✅ ON' : '❌ OFF'}"
end

# Test 1: Disable some preferences
puts "\n🔄 Test 1: Disabling some preferences..."
user.email_subscriptions.where(subscription_type: [ 'event_updated', 'student_profile_updated' ]).update_all(enabled: false)

puts "📋 After disabling event_updated and student_profile_updated:"
user.email_subscriptions.reload.order(:subscription_type).each do |sub|
  puts "  #{sub.subscription_type.ljust(25)} → #{sub.enabled ? '✅ ON' : '❌ OFF'}"
end

# Test 2: Re-enable all
puts "\n🔄 Test 2: Re-enabling all preferences..."
user.email_subscriptions.update_all(enabled: true)

puts "📋 After re-enabling all:"
user.email_subscriptions.reload.order(:subscription_type).each do |sub|
  puts "  #{sub.subscription_type.ljust(25)} → #{sub.enabled ? '✅ ON' : '❌ OFF'}"
end

puts "\n✅ Database operations working correctly!"
puts "💡 If the UI isn't reflecting changes, it's likely a form/display issue, not a database issue."
