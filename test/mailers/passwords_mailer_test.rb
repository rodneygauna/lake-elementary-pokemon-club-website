require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  def setup
    @user = users(:regular_user)
    # Note: Rails 8 automatically generates password_reset_token
    # No need to manually set it - it's available via the built-in method
  end

  test "reset email has correct subject and recipient" do
    email = PasswordsMailer.reset(@user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @user.email_address ], email.to
    assert_equal "Reset your password", email.subject
  end

  test "reset email includes both HTML and text parts" do
    email = PasswordsMailer.reset(@user)

    assert_equal 2, email.parts.size
    assert_includes email.parts.map(&:content_type), "text/html; charset=UTF-8"
    assert_includes email.parts.map(&:content_type), "text/plain; charset=UTF-8"
  end

  test "reset email HTML contains user information and reset link" do
    email = PasswordsMailer.reset(@user)
    html_part = email.parts.find { |part| part.content_type.include?("html") }

    assert_match @user.first_name, html_part.body.to_s
    assert_match @user.email_address, html_part.body.to_s
    assert_match @user.full_name, html_part.body.to_s
    # Check for password reset URL pattern instead of exact token
    assert_match /passwords\/.*\/edit/, html_part.body.to_s
    assert_match "Password Reset", html_part.body.to_s
    assert_match "15 minutes", html_part.body.to_s
  end

  test "reset email text version contains user information and reset link" do
    email = PasswordsMailer.reset(@user)
    text_part = email.parts.find { |part| part.content_type.include?("plain") }

    assert_match @user.first_name, text_part.body.to_s
    assert_match @user.email_address, text_part.body.to_s
    assert_match @user.full_name, text_part.body.to_s
    # Check for password reset URL pattern instead of exact token
    assert_match /passwords\/.*\/edit/, text_part.body.to_s
    assert_match "Password Reset", text_part.body.to_s
    assert_match "15 minutes", text_part.body.to_s
  end

  test "reset email follows security best practices" do
    email = PasswordsMailer.reset(@user)
    html_part = email.parts.find { |part| part.content_type.include?("html") }
    text_part = email.parts.find { |part| part.content_type.include?("plain") }

    # Both parts should mention security and time limits
    [ html_part, text_part ].each do |part|
      body = part.body.to_s.downcase
      assert_match /security/i, body
      assert_match /15 minutes/i, body
      assert_match /expire/i, body
    end
  end

  test "reset email includes Pokemon theme styling in HTML" do
    email = PasswordsMailer.reset(@user)
    html_part = email.parts.find { |part| part.content_type.include?("html") }

    # Check for Pokemon theme colors and styling
    assert_match "#0084FF", html_part.body.to_s # Electric Blue
    assert_match "Pokémon Club", html_part.body.to_s
    assert_match "Lake Elementary", html_part.body.to_s
  end

  test "reset email includes proper fallback URL in footer" do
    email = PasswordsMailer.reset(@user)
    html_part = email.parts.find { |part| part.content_type.include?("html") }
    text_part = email.parts.find { |part| part.content_type.include?("plain") }

    # Both should include password reset URL pattern
    [ html_part, text_part ].each do |part|
      assert_match /passwords\/.*\/edit/, part.body.to_s
    end
  end
end
