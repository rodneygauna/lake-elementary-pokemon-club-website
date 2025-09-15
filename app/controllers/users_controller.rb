class UsersController < ApplicationController
  before_action :require_authentication
  before_action :set_user, only: [ :show, :edit, :update ]
  before_action :ensure_own_profile, only: [ :edit, :update ]

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
