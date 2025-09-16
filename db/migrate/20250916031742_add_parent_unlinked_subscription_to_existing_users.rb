class AddParentUnlinkedSubscriptionToExistingUsers < ActiveRecord::Migration[8.0]
  def up
    # Add the new parent_unlinked subscription to all existing users
    User.find_each do |user|
      user.email_subscriptions.find_or_create_by(subscription_type: 'parent_unlinked') do |subscription|
        subscription.enabled = true
      end
    end
  end

  def down
    # Remove parent_unlinked subscriptions
    EmailSubscription.where(subscription_type: 'parent_unlinked').destroy_all
  end
end
