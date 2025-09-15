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
    @email_subscriptions = @user.email_subscriptions.includes(:user)
    @available_subscription_types = EmailSubscription.subscription_types_for_user
  end

  def update_email_preferences
    if params[:email_subscriptions].present?
      params[:email_subscriptions].each do |subscription_type, enabled|
        subscription = @user.email_subscriptions.find_or_initialize_by(subscription_type: subscription_type)
        subscription.update(enabled: enabled == "1")
      end
      redirect_to email_preferences_user_path, notice: "Email preferences updated successfully."
    else
      redirect_to email_preferences_user_path, alert: "No preferences were updated."
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
