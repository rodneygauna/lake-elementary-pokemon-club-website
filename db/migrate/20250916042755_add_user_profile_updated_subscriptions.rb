class AddUserProfileUpdatedSubscriptions < ActiveRecord::Migration[8.0]
  def up
    # Add user_profile_updated subscription for all existing users (enabled by default)
    User.find_each do |user|
      user.email_subscriptions.find_or_create_by(subscription_type: 'user_profile_updated') do |subscription|
        subscription.enabled = true
      end
    end
  end

  def down
    # Remove user_profile_updated subscriptions
    EmailSubscription.where(subscription_type: 'user_profile_updated').destroy_all
  end
end
