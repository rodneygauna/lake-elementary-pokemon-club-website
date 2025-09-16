class EmailSubscription < ApplicationRecord
  # Enums
  enum :subscription_type, {
    new_event: "new_event",
    event_cancelled: "event_cancelled",
    event_updated: "event_updated",
    student_attendance_updated: "student_attendance_updated",
    student_linked: "student_linked",
    student_unlinked: "student_unlinked",
    student_profile_updated: "student_profile_updated",
    new_parent_linked: "new_parent_linked"
  }

  # Associations
  belongs_to :user

  # Validations
  validates :subscription_type, presence: true, uniqueness: { scope: :user_id }
  validates :enabled, inclusion: { in: [ true, false ] }

  # Scopes
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }
  scope :for_subscription_type, ->(type) { where(subscription_type: type) }

  # Class methods
  def self.subscription_types_for_user
    subscription_types.keys
  end

  def self.default_subscriptions
    subscription_types.keys
  end
end
