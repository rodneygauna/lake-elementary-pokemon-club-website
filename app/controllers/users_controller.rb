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
    # Users can update their names, email and password, but not their role
    params.require(:user).permit(:first_name, :last_name, :email_address, :password, :password_confirmation)
  end

  def ensure_own_profile
    # This controller only allows users to edit their own profile
    # Admin user management is handled in Admin::UsersController
  end
end
