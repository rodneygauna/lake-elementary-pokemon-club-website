#!/usr/bin/env ruby

# Script to check email subscription status for all users
require_relative '../config/environment'

puts "📧 Email Subscription Status Report"
puts "=" * 50

User.joins(:email_subscriptions)
    .where(email_subscriptions: { subscription_type: 'new_parent_linked' })
    .includes(:email_subscriptions)
    .each do |user|
  subscription = user.email_subscriptions.find_by(subscription_type: 'new_parent_linked')
  puts "#{user.first_name} #{user.last_name} (#{user.email_address})"
  puts "  Status: #{user.status}"
  puts "  Role: #{user.role}"
  puts "  New Parent Linked subscription: #{subscription.enabled ? 'ENABLED' : 'DISABLED'}"

  # Show all their students
  students = user.students
  if students.any?
    puts "  Linked students: #{students.pluck(:first_name, :last_name).map { |f, l| "#{f} #{l}" }.join(', ')}"
  else
    puts "  Linked students: None"
  end
  puts ""
end

puts "\n🔍 Background Jobs Status:"
puts "Active Job Adapter: #{Rails.application.config.active_job.queue_adapter}"

# Check if there are any pending jobs (if using a persistent queue)
begin
  if defined?(ActiveJob::QueueAdapters::SolidQueueAdapter)
    puts "Solid Queue jobs pending: #{SolidQueue::Job.pending.count}"
  end
rescue
  puts "Could not check queue status (queue adapter: #{Rails.application.config.active_job.queue_adapter})"
end
