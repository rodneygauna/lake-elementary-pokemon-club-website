#!/usr/bin/env ruby

# Email Testing Utility for Development
require_relative '../config/environment'

def show_usage
  puts <<~USAGE
    📧 Email Testing Utility

    Usage: ruby script/email_utility.rb [command]

    Commands:
      status     - Show current email configuration
      clear      - Clear saved emails (file delivery)
      list       - List saved emails
      view PATTERN - View email(s) matching pattern
      test       - Send a test email
      config MODE - Switch delivery method

    Examples:
      ruby script/email_utility.rb status
      ruby script/email_utility.rb clear
      ruby script/email_utility.rb view attendance
      ruby script/email_utility.rb config file
  USAGE
end

def show_status
  puts "📧 Email Configuration Status"
  puts "=" * 40
  puts "Delivery method: #{ActionMailer::Base.delivery_method}"
  puts "Perform deliveries: #{ActionMailer::Base.perform_deliveries}"

  case ActionMailer::Base.delivery_method
  when :file
    mail_dir = Rails.root.join('tmp', 'mails')
    count = Dir.glob(File.join(mail_dir, "*")).size
    puts "Mail directory: #{mail_dir}"
    puts "Saved emails: #{count}"
  when :test
    puts "Test deliveries count: #{ActionMailer::Base.deliveries.size}"
  when :smtp
    puts "SMTP configured for external delivery"
  end
end

def clear_emails
  case ActionMailer::Base.delivery_method
  when :file
    mail_dir = Rails.root.join('tmp', 'mails')
    files = Dir.glob(File.join(mail_dir, "*"))
    files.each { |f| File.delete(f) }
    puts "✅ Cleared #{files.size} saved emails"
  when :test
    count = ActionMailer::Base.deliveries.size
    ActionMailer::Base.deliveries.clear
    puts "✅ Cleared #{count} test deliveries"
  else
    puts "❌ Cannot clear emails for #{ActionMailer::Base.delivery_method} delivery method"
  end
end

def list_emails
  case ActionMailer::Base.delivery_method
  when :file
    mail_dir = Rails.root.join('tmp', 'mails')
    files = Dir.glob(File.join(mail_dir, "*"))

    if files.empty?
      puts "📭 No saved emails found"
    else
      puts "📧 Saved Emails:"
      files.each do |file|
        size = File.size(file)
        mtime = File.mtime(file).strftime("%Y-%m-%d %H:%M:%S")
        basename = File.basename(file)
        puts "  #{basename} (#{size} bytes, #{mtime})"
      end
    end
  when :test
    count = ActionMailer::Base.deliveries.size
    puts "📧 Test Deliveries: #{count}"
    ActionMailer::Base.deliveries.each_with_index do |email, i|
      puts "  #{i+1}. To: #{email.to.join(', ')} | Subject: #{email.subject}"
    end
  else
    puts "❌ Cannot list emails for #{ActionMailer::Base.delivery_method} delivery method"
  end
end

def view_emails(pattern = nil)
  case ActionMailer::Base.delivery_method
  when :file
    mail_dir = Rails.root.join('tmp', 'mails')
    files = Dir.glob(File.join(mail_dir, "*"))

    if pattern
      files = files.select { |f| File.basename(f).include?(pattern) }
    end

    if files.empty?
      puts "📭 No matching emails found"
    else
      files.each do |file|
        puts "\n" + "=" * 50
        puts "📧 #{File.basename(file)}"
        puts "=" * 50

        content = File.read(file)
        # Show headers
        headers = content.split("\n\n").first
        puts headers
        puts "\n[Email body truncated - use 'cat #{file}' to view full content]"
      end
    end
  when :test
    emails = ActionMailer::Base.deliveries
    if pattern
      emails = emails.select { |e| e.to.any? { |addr| addr.include?(pattern) } || e.subject.include?(pattern) }
    end

    emails.each_with_index do |email, i|
      puts "\n" + "=" * 50
      puts "📧 Email #{i+1}"
      puts "=" * 50
      puts "To: #{email.to.join(', ')}"
      puts "Subject: #{email.subject}"
      puts "Body: #{email.body.to_s[0..200]}..."
    end
  end
end

def send_test_email
  # Find a test user and student
  user = User.where(status: 'active').first
  student = Student.where(status: 'active').first

  if user.nil? || student.nil?
    puts "❌ No active users or students found for testing"
    return
  end

  puts "📧 Sending test email..."
  puts "   To: #{user.email_address}"
  puts "   Student: #{student.full_name}"

  begin
    # Send a student profile update notification as test
    NotificationMailer.student_profile_updated(user, student, [ 'test_field' ]).deliver_now
    puts "✅ Test email sent successfully"
  rescue => e
    puts "❌ Failed to send test email: #{e.message}"
  end
end

# Main script logic
command = ARGV[0]&.downcase
argument = ARGV[1]

case command
when 'status', 's'
  show_status
when 'clear', 'c'
  clear_emails
when 'list', 'l'
  list_emails
when 'view', 'v'
  view_emails(argument)
when 'test', 't'
  send_test_email
when 'config'
  puts "📧 Configuration changes should be made in config/environments/development.rb"
  puts "   Current method: #{ActionMailer::Base.delivery_method}"
when nil, 'help', 'h', '--help'
  show_usage
else
  puts "❌ Unknown command: #{command}"
  puts ""
  show_usage
end
