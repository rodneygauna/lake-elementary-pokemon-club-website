class Admin::UsersController < ApplicationController
  before_action :require_admin_access
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.order(:email_address)

    # Filter out inactive users unless specifically requested
    unless params[:show_inactive] == "true"
      @users = @users.where(status: "active")
    end
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # Set a temporary password that user must change on first login
    temp_password = SecureRandom.alphanumeric(12)
    @user.password = temp_password
    @user.password_confirmation = temp_password

    if @user.save
      redirect_to admin_user_path(@user), notice: "User was successfully created. Temporary password: #{temp_password}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Prevent admin from deleting themselves
    if @user == current_user
      redirect_to admin_users_path, alert: "You cannot delete your own account."
      return
    end

    @user.destroy!
    redirect_to admin_users_path, notice: "User was successfully deleted."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email_address, :phone_number, :role, :status)
  end

  def require_admin_access
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
end
