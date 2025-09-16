#!/usr/bin/env ruby

# Comprehensive test for the complete user profile notification system
require_relative '../config/environment'

puts "🧪 Comprehensive User Profile Notification System Test"
puts "=" * 60

def test_results
  @test_results ||= { passed: 0, failed: 0, messages: [] }
end

def assert_test(description, condition)
  if condition
    test_results[:passed] += 1
    test_results[:messages] << "✅ #{description}"
  else
    test_results[:failed] += 1
    test_results[:messages] << "❌ #{description}"
  end
end

def print_results
  puts "\nTest Results:"
  puts "=" * 30
  test_results[:messages].each { |msg| puts msg }
  puts "\n📊 Summary: #{test_results[:passed]} passed, #{test_results[:failed]} failed"
  puts test_results[:failed] == 0 ? "🎉 All tests passed!" : "⚠️  Some tests failed"
end

begin
  # 1. Test EmailSubscription model has new subscription type
  puts "1. Testing EmailSubscription model..."
  assert_test(
    "user_profile_updated subscription type exists",
    EmailSubscription.subscription_types.key?('user_profile_updated')
  )

  # 2. Test NotificationMailer has new method
  puts "\n2. Testing NotificationMailer..."
  assert_test(
    "user_profile_updated mailer method exists",
    NotificationMailer.respond_to?(:user_profile_updated)
  )

  # 3. Test email templates exist
  puts "\n3. Testing email templates..."
  html_template = File.exist?('app/views/notification_mailer/user_profile_updated.html.erb')
  text_template = File.exist?('app/views/notification_mailer/user_profile_updated.text.erb')

  assert_test("HTML email template exists", html_template)
  assert_test("Text email template exists", text_template)

  # 4. Test helper methods
  puts "\n4. Testing helper methods..."
  helper = ApplicationHelper.new rescue Object.new.extend(ApplicationHelper)

  title = helper.subscription_type_title('user_profile_updated')
  description = helper.subscription_type_description('user_profile_updated')

  assert_test("Helper returns proper title", title == "Your Profile Changes")
  assert_test("Helper returns proper description", description.include?("profile information"))

  # 5. Test user subscription creation
  puts "\n5. Testing user subscription creation..."
  test_user = User.create!(
    first_name: 'Test',
    last_name: 'System',
    email_address: 'test-system@example.com',
    password: 'password123',
    role: 'user',
    status: 'active'
  )

  # Create default subscriptions
  test_user.create_default_subscriptions!

  assert_test(
    "User has user_profile_updated subscription",
    test_user.subscribed_to?(:user_profile_updated)
  )

  # 6. Test email generation
  puts "\n6. Testing email generation..."
  email = NotificationMailer.user_profile_updated(
    test_user,
    [ 'first_name', 'password_digest' ],
    false,
    nil
  )

  assert_test("Email generates without errors", !email.nil?)
  assert_test("Email has correct subject", email.subject.include?("Profile Has Been Updated"))
  assert_test("Email sent to correct recipient", email.to.include?(test_user.email_address))

  # 7. Test admin email generation
  puts "\n7. Testing admin email generation..."
  admin_user = User.create!(
    first_name: 'Admin',
    last_name: 'Test',
    email_address: 'admin-test-system@example.com',
    password: 'password123',
    role: 'admin',
    status: 'active'
  )

  admin_email = NotificationMailer.user_profile_updated(
    test_user,
    [ 'role' ],
    true,
    admin_user
  )

  assert_test("Admin email generates without errors", !admin_email.nil?)
  assert_test("Admin email has correct subject", admin_email.subject.include?("Updated by an Administrator"))

  # 8. Test email content
  puts "\n8. Testing email content..."
  text_part = email.parts.find { |part| part.content_type.include?('text/plain') }
  html_part = email.parts.find { |part| part.content_type.include?('text/html') }

  assert_test("Email has text part", !text_part.nil?)
  assert_test("Email has HTML part", !html_part.nil?)

  if text_part
    text_body = text_part.body.to_s
    assert_test("Text email contains password notification", text_body.include?("Password"))
    assert_test("Text email contains first name change", text_body.include?("First Name"))
  end

  # 9. Test User model callback integration
  puts "\n9. Testing User model callback integration..."

  # Test that the callback method exists
  assert_test("User model has callback method", test_user.respond_to?(:send_profile_update_notification, true))

  # Test updating user profile (this should trigger notification if implemented correctly)
  # Note: In a real test, we'd want to mock the mailer to avoid sending actual emails
  original_first_name = test_user.first_name
  test_user.update!(first_name: 'UpdatedName')

  assert_test("User profile update succeeded", test_user.reload.first_name == 'UpdatedName')

  # Revert the change
  test_user.update!(first_name: original_first_name)

  # Clean up test users
  test_user.destroy
  admin_user.destroy

  puts "\n✅ Test data cleaned up"

rescue => e
  test_results[:failed] += 1
  test_results[:messages] << "❌ System error: #{e.message}"
  puts "\nError occurred: #{e.message}"
  puts e.backtrace.first(3).join("\n")

  # Clean up on error
  User.where(email_address: [ 'test-system@example.com', 'admin-test-system@example.com' ]).destroy_all
end

print_results

puts "\n" + "=" * 60
puts "🧪 Comprehensive test completed"
