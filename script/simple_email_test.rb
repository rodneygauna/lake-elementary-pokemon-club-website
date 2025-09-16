#!/usr/bin/env ruby

# Simple email test
require_relative '../config/environment'

puts "🔍 Simple Email Delivery Test"
puts "=" * 30

# Clear existing deliveries
ActionMailer::Base.deliveries.clear
puts "Cleared existing deliveries"

# Find test user
parent = User.find_by(email_address: "parent1@test.com")
student = Student.find_by(first_name: "TestChild")

if parent.nil? || student.nil?
  puts "❌ Test data not found"
  exit 1
end

# Check ActionMailer configuration
puts "\nActionMailer configuration:"
puts "  delivery_method: #{ActionMailer::Base.delivery_method}"
puts "  perform_deliveries: #{ActionMailer::Base.perform_deliveries}"

# Try to send an email
puts "\nSending test email..."
begin
  email = NotificationMailer.student_unlinked(parent, student)
  puts "Email created: #{email.subject}"
  email.deliver_now
  puts "Email delivery attempted"
rescue => e
  puts "❌ Error: #{e.message}"
end

# Check deliveries
puts "\nDeliveries count: #{ActionMailer::Base.deliveries.size}"
if ActionMailer::Base.deliveries.any?
  ActionMailer::Base.deliveries.each_with_index do |email, i|
    puts "  Email #{i+1}: #{email.subject} to #{email.to.first}"
  end
else
  puts "  No emails in deliveries array"
end

puts "\n" + "=" * 30
