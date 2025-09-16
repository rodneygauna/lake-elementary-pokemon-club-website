class AddNewParentLinkedSubscriptionToExistingUsers < ActiveRecord::Migration[8.0]
  def up
    # Add the new_parent_linked subscription to all existing users
    User.find_each do |user|
      user.email_subscriptions.find_or_create_by(subscription_type: "new_parent_linked") do |subscription|
        subscription.enabled = true
      end
    end
  end

  def down
    # Remove the new_parent_linked subscription from all users
    EmailSubscription.where(subscription_type: "new_parent_linked").delete_all
  end
end
