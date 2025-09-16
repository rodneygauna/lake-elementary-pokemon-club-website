require "test_helper"

class WelcomeEmailTest < ActionMailer::TestCase
  def setup
    @user = users(:regular_user)
    @admin = users(:admin_user)
  end

  test "new_user_welcome generates email with correct content" do
    temp_password = "TempPass123"

    email = NotificationMailer.new_user_welcome(@user, temp_password, false, nil)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @user.email_address ], email.to
    assert_equal "🎉 Welcome to Lake Elementary Pokémon Club!", email.subject

    # Check HTML part content
    html_part = email.parts.find { |part| part.content_type.include?("html") }
    assert_not html_part.body.to_s.blank?
    assert_match @user.first_name, html_part.body.to_s
    assert_match temp_password, html_part.body.to_s
    assert_match "temporary password", html_part.body.to_s.downcase
    assert_match "change your password", html_part.body.to_s.downcase
  end

  test "new_user_welcome includes admin context when created by admin" do
    temp_password = "AdminPass456"

    email = NotificationMailer.new_user_welcome(@user, temp_password, true, @admin)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @user.email_address ], email.to

    # Check HTML part for admin context
    html_part = email.parts.find { |part| part.content_type.include?("html") }
    assert_match @admin.first_name, html_part.body.to_s
    assert_match "created by", html_part.body.to_s.downcase
  end

  test "new_user_welcome includes both HTML and text parts" do
    temp_password = "TestPass789"

    email = NotificationMailer.new_user_welcome(@user, temp_password, false, nil)

    assert_equal 2, email.parts.size
    assert_includes email.parts.map(&:content_type), "text/html; charset=UTF-8"
    assert_includes email.parts.map(&:content_type), "text/plain; charset=UTF-8"

    # Check both parts contain the password
    html_part = email.parts.find { |part| part.content_type.include?("html") }
    text_part = email.parts.find { |part| part.content_type.include?("plain") }

    assert_match temp_password, html_part.body.to_s
    assert_match temp_password, text_part.body.to_s
  end

  test "user model sends welcome email on create with temporary password" do
    # Setup for user creation with temporary password
    user_attrs = {
      first_name: "New",
      last_name: "User",
      email_address: "newuser@example.com",
      role: "user",
      status: "active",
      password: "temp123",
      password_confirmation: "temp123"
    }

    new_user = User.new(user_attrs)
    new_user.temporary_password_for_email = "temp123"

    assert_emails 1 do
      new_user.save!
    end
  end

  test "user model does not send welcome email when no temporary password set" do
    # Setup for user creation without temporary password (e.g., self-registration)
    user_attrs = {
      first_name: "Self",
      last_name: "Register",
      email_address: "selfregister@example.com",
      role: "user",
      status: "active",
      password: "password123",
      password_confirmation: "password123"
    }

    new_user = User.new(user_attrs)
    # Don't set temporary_password_for_email

    assert_emails 0 do
      new_user.save!
    end
  end
end
