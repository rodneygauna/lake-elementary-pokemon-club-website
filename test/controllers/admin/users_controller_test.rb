require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = users(:admin_user)
    @super_user = users(:super_user)
    @regular_user = users(:regular_user)
  end

  test "should redirect to login when not authenticated" do
    get admin_users_path
    assert_redirected_to new_session_path
  end

  test "should redirect regular users away from admin area" do
    login_as(@regular_user)
    get admin_users_path
    assert_response :redirect
  end

  test "should allow admin access to admin area" do
    login_as(@admin_user)
    get admin_users_path
    assert_response :success
  end

  test "should allow super_user access to admin area" do
    login_as(@super_user)
    get admin_users_path
    assert_response :success
  end

  test "should show user details to admin" do
    login_as(@admin_user)
    get admin_user_path(@regular_user)
    assert_response :success
    assert_includes response.body, @regular_user.full_name
  end

  test "should get new user form for admin" do
    login_as(@admin_user)
    get new_admin_user_path
    assert_response :success
    assert_includes response.body, "Create New User"
  end

  test "should get edit user form for admin" do
    login_as(@admin_user)
    get edit_admin_user_path(@regular_user)
    assert_response :success
    assert_includes response.body, "Edit User"
  end

  # User creation tests
  test "admin should be able to create users with any role" do
    login_as(@admin_user)
    assert_difference("User.count") do
      post admin_users_path, params: {
        user: {
          first_name: "New",
          last_name: "Admin",
          email_address: "newadmin@test.com",
          role: "admin",
          status: "active"
        }
      }
    end
    new_user = User.find_by(email_address: "newadmin@test.com")
    assert_equal "admin", new_user.role
    assert_redirected_to admin_user_path(new_user)
  end

  test "super_user should be able to create users with user and super_user roles" do
    login_as(@super_user)
    assert_difference("User.count") do
      post admin_users_path, params: {
        user: {
          first_name: "New",
          last_name: "SuperUser",
          email_address: "newsuperuser@test.com",
          role: "super_user",
          status: "active"
        }
      }
    end
    new_user = User.find_by(email_address: "newsuperuser@test.com")
    assert_equal "super_user", new_user.role
  end

  test "super_user should not be able to create admin users" do
    login_as(@super_user)
    assert_no_difference("User.count") do
      post admin_users_path, params: {
        user: {
          first_name: "New",
          last_name: "Admin",
          email_address: "newadmin@test.com",
          role: "admin",
          status: "active"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # User update tests
  test "admin should be able to update any user's role" do
    login_as(@admin_user)
    patch admin_user_path(@regular_user), params: {
      user: {
        first_name: @regular_user.first_name,
        last_name: @regular_user.last_name,
        email_address: @regular_user.email_address,
        role: "super_user",
        status: @regular_user.status
      }
    }
    assert_redirected_to admin_user_path(@regular_user)
    assert_equal "super_user", @regular_user.reload.role
  end

  test "super_user should be able to update regular user's role to super_user" do
    login_as(@super_user)
    patch admin_user_path(@regular_user), params: {
      user: {
        first_name: @regular_user.first_name,
        last_name: @regular_user.last_name,
        email_address: @regular_user.email_address,
        role: "super_user",
        status: @regular_user.status
      }
    }
    assert_redirected_to admin_user_path(@regular_user)
    assert_equal "super_user", @regular_user.reload.role
  end

  test "super_user should not be able to update user to admin role" do
    login_as(@super_user)
    original_role = @regular_user.role
    patch admin_user_path(@regular_user), params: {
      user: {
        first_name: @regular_user.first_name,
        last_name: @regular_user.last_name,
        email_address: @regular_user.email_address,
        role: "admin",
        status: @regular_user.status
      }
    }
    assert_redirected_to admin_user_path(@regular_user)
    assert_equal original_role, @regular_user.reload.role
    assert_equal "You don't have permission to assign that role.", flash[:alert]
  end

  test "super_user should not be able to edit admin users" do
    login_as(@super_user)
    get edit_admin_user_path(@admin_user)
    assert_redirected_to admin_users_path
    assert_equal "You don't have permission to edit this user.", flash[:alert]
  end

  # Delete tests
  test "only admin should be able to delete users" do
    login_as(@admin_user)
    assert_difference("User.count", -1) do
      delete admin_user_path(@regular_user)
    end
    assert_redirected_to admin_users_path
  end

  test "super_user should not be able to delete users" do
    login_as(@super_user)
    assert_no_difference("User.count") do
      delete admin_user_path(@regular_user)
    end
    assert_response :redirect # Should be redirected away
  end

  test "admin should not be able to delete themselves" do
    login_as(@admin_user)
    assert_no_difference("User.count") do
      delete admin_user_path(@admin_user)
    end
    assert_redirected_to admin_users_path
    assert_equal "You cannot delete your own account.", flash[:alert]
  end

  # Filtering tests
  test "should filter inactive users by default" do
    login_as(@admin_user)
    get admin_users_path
    assert_response :success
    assert_not_includes response.body, users(:inactive_user).full_name
  end

  test "should show inactive users when requested" do
    login_as(@admin_user)
    get admin_users_path, params: { show_inactive: "true" }
    assert_response :success
    assert_includes response.body, users(:inactive_user).full_name
  end

  private

  def login_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end
