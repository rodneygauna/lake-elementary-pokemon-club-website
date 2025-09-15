require "test_helper"

class EventTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @published_event = events(:published_event)
    @draft_event = events(:draft_event)
    @canceled_event = events(:canceled_event)
    @valid_attributes = {
      title: "Test Event",
      description: "A test event",
      starts_at: 1.day.from_now,
      ends_at: 1.day.from_now + 2.hours,
      time_zone: "America/Los_Angeles",
      status: "published"
    }
  end

  # Test validations
  test "should be valid with valid attributes" do
    event = Event.new(@valid_attributes)
    assert event.valid?
  end

  test "should require title" do
    event = Event.new(@valid_attributes.except(:title))
    assert_not event.valid?
    assert_includes event.errors[:title], "can't be blank"
  end

  test "should require starts_at" do
    event = Event.new(@valid_attributes.except(:starts_at))
    assert_not event.valid?
    assert_includes event.errors[:starts_at], "can't be blank"
  end

  test "should require ends_at" do
    event = Event.new(@valid_attributes.except(:ends_at))
    assert_not event.valid?
    assert_includes event.errors[:ends_at], "can't be blank"
  end

  # Note: time_zone and status have database defaults, so presence validation
  # is handled at the DB level rather than model validation level

  test "should validate ends_at is after starts_at" do
    event = Event.new(@valid_attributes.merge(
      starts_at: 1.day.from_now,
      ends_at: 1.day.from_now - 1.hour
    ))
    assert_not event.valid?
    assert_includes event.errors[:ends_at], "must be after the start time"
  end

  # Test enums
  test "should have status enum" do
    assert_equal "published", @published_event.status
    assert_equal "draft", @draft_event.status
    assert_equal "canceled", @canceled_event.status

    assert @published_event.published?
    assert @draft_event.draft?
    assert @canceled_event.canceled?
  end

  # Test associations
  test "should have many attendances" do
    assert_respond_to @published_event, :attendances
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @published_event.attendances
  end

  test "should have many attending_students" do
    assert_respond_to @published_event, :attending_students
  end

  # Test scopes
  test "upcoming scope should return future events" do
    upcoming_events = Event.upcoming
    assert_includes upcoming_events, @published_event
    assert_includes upcoming_events, @draft_event
    assert_not_includes upcoming_events, @canceled_event
  end

  test "past scope should return past events" do
    past_events = Event.past
    assert_includes past_events, @canceled_event
    assert_not_includes past_events, @published_event
    assert_not_includes past_events, @draft_event
  end

  test "published scope should return published events" do
    published_events = Event.published
    assert_includes published_events, @published_event
    assert_not_includes published_events, @draft_event
    assert_not_includes published_events, @canceled_event
  end

  test "draft scope should return draft events" do
    draft_events = Event.draft
    assert_includes draft_events, @draft_event
    assert_not_includes draft_events, @published_event
    assert_not_includes draft_events, @canceled_event
  end

  test "canceled scope should return canceled events" do
    canceled_events = Event.canceled
    assert_includes canceled_events, @canceled_event
    assert_not_includes canceled_events, @published_event
    assert_not_includes canceled_events, @draft_event
  end

  test "visible_to_public scope should return published and canceled events" do
    public_events = Event.visible_to_public
    assert_includes public_events, @published_event
    assert_includes public_events, @canceled_event
    assert_not_includes public_events, @draft_event
  end

  # Test callbacks
  test "should set default time zone if not provided" do
    event = Event.create!(@valid_attributes.except(:time_zone))
    assert_not_nil event.time_zone
  end

  # Test email notification callbacks
  test "should enqueue new event notification job when creating published event" do
    # Set up user with subscription (use find_or_create to avoid duplication)
    user = users(:regular_user)
    EmailSubscription.find_or_create_by(user: user, subscription_type: "new_event") do |sub|
      sub.enabled = true
    end

    assert_enqueued_jobs 1, only: NotificationJob do
      Event.create!(@valid_attributes.merge(status: "published"))
    end
  end

  test "should not enqueue jobs when creating draft event" do
    user = users(:regular_user)
    EmailSubscription.find_or_create_by(user: user, subscription_type: "new_event") do |sub|
      sub.enabled = true
    end

    assert_no_enqueued_jobs only: NotificationJob do
      Event.create!(@valid_attributes.merge(status: "draft"))
    end
  end

  test "should enqueue update notification job when significant fields change" do
    user = users(:regular_user)
    EmailSubscription.find_or_create_by(user: user, subscription_type: "event_updated") do |sub|
      sub.enabled = true
    end

    assert_enqueued_jobs 1, only: NotificationJob do
      @published_event.update!(title: "Updated Title")
    end
  end

  test "should enqueue cancellation notification job when status changes to canceled" do
    user = users(:regular_user)
    EmailSubscription.find_or_create_by(user: user, subscription_type: "event_cancelled") do |sub|
      sub.enabled = true
    end

    assert_enqueued_jobs 1, only: NotificationJob do
      @published_event.update!(status: "canceled")
    end
  end

  test "should not enqueue jobs when insignificant fields change" do
    user = users(:regular_user)
    EmailSubscription.find_or_create_by(user: user, subscription_type: "event_updated") do |sub|
      sub.enabled = true
    end

    assert_no_enqueued_jobs only: NotificationJob do
      @published_event.update!(special: true) # Not in significant_changes list
    end
  end

  test "should not enqueue jobs for draft event updates" do
    user = users(:regular_user)
    EmailSubscription.find_or_create_by(user: user, subscription_type: "event_updated") do |sub|
      sub.enabled = true
    end

    assert_no_enqueued_jobs only: NotificationJob do
      @draft_event.update!(title: "Updated Draft Title")
    end
  end

  # Test instance methods (if any exist in the model)
  test "should respond to attendance methods" do
    # Test that the event can find its attendances
    assert_respond_to @published_event, :attendances
  end
end
