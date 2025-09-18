class UsersController < ApplicationController
  before_action :require_authentication
  before_action :set_user, only: [ :show, :edit, :update, :email_preferences, :update_email_preferences ]
  before_action :ensure_own_profile, only: [ :edit, :update, :email_preferences, :update_email_preferences ]

  def show
    # Users can only view their own profile
    @user = current_user
  end

  def edit
  end

  def update
    # Check if role is being changed and validate permission
    if params[:user][:role].present? && params[:user][:role] != @user.role
      unless current_user.admin_level?
        redirect_to user_path, alert: "You don't have permission to change roles."
        return
      end

      unless current_user.can_assign_role?(params[:user][:role])
        redirect_to user_path, alert: "You don't have permission to assign that role."
        return
      end
    end

    if @user.update(user_params)
      redirect_to user_path, notice: "Your profile was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def email_preferences
    @email_subscriptions = @user.email_subscriptions.reload
    @available_subscription_types = EmailSubscription.subscription_types_for_user
  end

  def update_email_preferences
    # Get all available subscription types for the user
    all_subscription_types = %w[
      new_event event_cancelled event_updated
      student_attendance_updated student_profile_updated
      student_linked student_unlinked new_parent_linked parent_unlinked user_profile_updated
    ]

    if params[:email_subscriptions].present?
      # Update all subscription types - present ones get their value, missing ones get disabled
      all_subscription_types.each do |subscription_type|
        subscription = @user.email_subscriptions.find_or_initialize_by(subscription_type: subscription_type)
        # If the subscription type is in the params, use its value, otherwise set to false (unchecked)
        enabled = params[:email_subscriptions][subscription_type] == "1"
        subscription.update(enabled: enabled)
      end
      redirect_to email_preferences_user_path, notice: "Email preferences updated successfully."
    else
      # If no email_subscriptions params are present, disable all subscriptions
      all_subscription_types.each do |subscription_type|
        subscription = @user.email_subscriptions.find_or_initialize_by(subscription_type: subscription_type)
        subscription.update(enabled: false)
      end
      redirect_to email_preferences_user_path, notice: "All email notifications have been disabled."
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    permitted_params = [ :first_name, :last_name, :email_address, :password, :password_confirmation ]

    # Allow role changes for admin_level users
    if current_user.admin_level?
      permitted_params << :role
    end

    params.require(:user).permit(permitted_params)
  end

  def ensure_own_profile
    # This controller only allows users to edit their own profile
    # Admin user management is handled in Admin::UsersController
  end
end
