require "test_helper"

class EmailPreferencesTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:admin_user)
    @user.create_default_subscriptions!
    post session_path, params: {
      email_address: @user.email_address,
      password: "password123"
    }
  end

  test "email preferences page displays current settings correctly" do
    # Enable some subscriptions, disable others
    @user.email_subscriptions.where(subscription_type: [ "new_event", "event_cancelled" ]).update_all(enabled: true)
    @user.email_subscriptions.where(subscription_type: [ "event_updated", "student_profile_updated" ]).update_all(enabled: false)

    get email_preferences_user_path
    assert_response :success

    # Check that enabled checkboxes are checked
    assert_select "input[name='email_subscriptions[new_event]'][checked='checked']"
    assert_select "input[name='email_subscriptions[event_cancelled]'][checked='checked']"

    # Check that disabled checkboxes are NOT checked
    assert_select "input[name='email_subscriptions[event_updated]']:not([checked])"
    assert_select "input[name='email_subscriptions[student_profile_updated]']:not([checked])"
  end

  test "updating email preferences saves changes correctly" do
    # Start with all enabled
    @user.email_subscriptions.update_all(enabled: true)

    # Submit form with only some preferences enabled
    patch update_email_preferences_user_path, params: {
      email_subscriptions: {
        new_event: "1",
        event_cancelled: "1"
        # Intentionally omitting other types to test unchecked behavior
      }
    }

    assert_redirected_to email_preferences_user_path
    follow_redirect!
    assert_match "Email preferences updated successfully", flash[:notice]

    # Verify database changes
    @user.reload
    assert @user.email_subscriptions.find_by(subscription_type: "new_event").enabled
    assert @user.email_subscriptions.find_by(subscription_type: "event_cancelled").enabled
    assert_not @user.email_subscriptions.find_by(subscription_type: "event_updated").enabled
    assert_not @user.email_subscriptions.find_by(subscription_type: "student_profile_updated").enabled

    # Verify UI reflects changes
    assert_select "input[name='email_subscriptions[new_event]'][checked='checked']"
    assert_select "input[name='email_subscriptions[event_cancelled]'][checked='checked']"
    assert_select "input[name='email_subscriptions[event_updated]']:not([checked])"
    assert_select "input[name='email_subscriptions[student_profile_updated]']:not([checked])"
  end

  test "submitting empty form disables all preferences" do
    # Start with all enabled
    @user.email_subscriptions.update_all(enabled: true)

    # Submit form with no checkboxes checked
    patch update_email_preferences_user_path, params: {}

    assert_redirected_to email_preferences_user_path
    follow_redirect!
    assert_match "All email notifications have been disabled", flash[:notice]

    # Verify all preferences are disabled
    @user.reload
    @user.email_subscriptions.each do |subscription|
      assert_not subscription.enabled, "#{subscription.subscription_type} should be disabled"
    end
  end
end
