require "test_helper"

class EmailSubscriptionTest < ActiveSupport::TestCase
  def setup
    @user = users(:regular_user)
    @subscription = email_subscriptions(:regular_new_events)
  end

  # Test validations
  test "should be valid with valid attributes" do
    subscription = EmailSubscription.new(
      user: @user,
      subscription_type: "new_event",
      enabled: true
    )
    assert subscription.valid?
  end

  test "should require user" do
    subscription = EmailSubscription.new(subscription_type: "new_event", enabled: true)
    assert_not subscription.valid?
    assert_includes subscription.errors[:user], "must exist"
  end

  test "should require subscription_type" do
    subscription = EmailSubscription.new(user: @user, enabled: true)
    assert_not subscription.valid?
    assert_includes subscription.errors[:subscription_type], "can't be blank"
  end

  test "should require enabled to be present" do
    subscription = EmailSubscription.new(user: @user, subscription_type: "new_event")
    # enabled should default to true
    assert subscription.valid?
    assert subscription.enabled?
  end

  test "should enforce uniqueness of user and subscription_type" do
    # Create first subscription
    EmailSubscription.create!(user: @user, subscription_type: "new_event", enabled: true)

    # Try to create duplicate
    duplicate = EmailSubscription.new(user: @user, subscription_type: "new_event", enabled: false)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:subscription_type], "has already been taken"
  end

  # Test enum values
  test "should have correct subscription_type enum values" do
    expected_types = %w[
      new_event
      event_cancelled
      event_updated
      student_attendance_updated
      student_linked
      student_unlinked
      student_profile_updated
    ]

    expected_types.each do |type|
      subscription = EmailSubscription.new(user: @user, subscription_type: type, enabled: true)
      assert subscription.valid?, "#{type} should be a valid subscription_type"
    end
  end

  test "should reject invalid subscription_type" do
    assert_raises(ArgumentError) do
      EmailSubscription.new(user: @user, subscription_type: "invalid_type", enabled: true)
    end
  end

  # Test associations
  test "should belong to user" do
    assert_equal @user, @subscription.user
  end

  # Test scopes
  test "enabled scope should return only enabled subscriptions" do
    EmailSubscription.create!(user: @user, subscription_type: "event_updated", enabled: false)
    enabled_subscription = EmailSubscription.create!(user: @user, subscription_type: "event_cancelled", enabled: true)

    enabled_subscriptions = EmailSubscription.enabled
    assert_includes enabled_subscriptions, enabled_subscription
    assert_includes enabled_subscriptions, @subscription # fixture is enabled
  end

  test "disabled scope should return only disabled subscriptions" do
    disabled_subscription = EmailSubscription.create!(user: @user, subscription_type: "event_updated", enabled: false)

    disabled_subscriptions = EmailSubscription.disabled
    assert_includes disabled_subscriptions, disabled_subscription
    assert_not_includes disabled_subscriptions, @subscription
  end

  test "for_subscription_type scope should filter by type" do
    new_events_subs = EmailSubscription.for_subscription_type("new_event")
    assert_includes new_events_subs, @subscription

    # Create different type
    event_updates_sub = EmailSubscription.create!(user: @user, subscription_type: "event_updated", enabled: true)
    assert_not_includes new_events_subs, event_updates_sub
  end

  # Test class methods
  test "default_subscriptions should return all subscription types" do
    defaults = EmailSubscription.default_subscriptions

    expected_types = %w[
      new_event
      event_cancelled
      event_updated
      student_attendance_updated
      student_linked
      student_unlinked
      student_profile_updated
    ]

    assert_equal expected_types.sort, defaults.keys.sort

    # All should default to enabled except potentially sensitive ones
    assert defaults["new_event"]
    assert defaults["event_cancelled"]
    assert defaults["event_updated"]
    assert defaults["student_linked"]
    assert defaults["student_unlinked"]
    assert defaults["student_profile_updated"]
    # Attendance updates might be opt-in only
    assert_includes [ true, false ], defaults["student_attendance_updated"]
  end

  test "create_defaults_for_user should create all default subscriptions" do
    new_user = User.create!(
      first_name: "Test",
      last_name: "User",
      email_address: "test@example.com",
      password: "password123",
      role: "user"
    )

    # Should start with no subscriptions
    assert_equal 0, new_user.email_subscriptions.count

    EmailSubscription.create_defaults_for_user(new_user)

    # Should now have all 7 subscription types
    assert_equal 7, new_user.email_subscriptions.count

    expected_types = %w[
      new_event
      event_cancelled
      event_updated
      student_attendance_updated
      student_linked
      student_unlinked
      student_profile_updated
    ]

    created_types = new_user.email_subscriptions.pluck(:subscription_type).sort
    assert_equal expected_types.sort, created_types
  end

  # Test instance methods
  test "to_s should return readable format" do
    expected = "EmailSubscription: #{@subscription.user.email_address} -> #{@subscription.subscription_type} (enabled: #{@subscription.enabled})"
    assert_equal expected, @subscription.to_s
  end
end
