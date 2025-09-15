require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = users(:admin_user)
    @super_user = users(:super_user)
    @regular_user = users(:regular_user)
  end

  test "should redirect to login when not authenticated" do
    get user_path
    assert_redirected_to new_session_path
  end

  test "should show own profile when authenticated" do
    login_as(@regular_user)
    get user_path
    assert_response :success
    assert_includes response.body, @regular_user.full_name
  end

  test "should get edit form when authenticated" do
    login_as(@regular_user)
    get edit_user_path
    assert_response :success
    assert_includes response.body, "Edit My Profile"
  end

  test "should update own profile with valid attributes" do
    login_as(@regular_user)
    patch user_path, params: {
      user: {
        first_name: "Updated",
        last_name: "Name",
        email_address: @regular_user.email_address
      }
    }
    assert_redirected_to user_path
    assert_equal "Updated", @regular_user.reload.first_name
  end

  test "should not update with invalid attributes" do
    login_as(@regular_user)
    patch user_path, params: {
      user: {
        first_name: "",
        email_address: "invalid-email"
      }
    }
    assert_response :unprocessable_entity
  end

  # Role change tests
  test "regular user should not be able to change their role" do
    login_as(@regular_user)
    patch user_path, params: {
      user: {
        first_name: @regular_user.first_name,
        last_name: @regular_user.last_name,
        email_address: @regular_user.email_address,
        role: "admin"
      }
    }
    assert_redirected_to user_path
    assert_equal "user", @regular_user.reload.role
    assert_equal "You don't have permission to change roles.", flash[:alert]
  end

  test "admin should be able to change their role" do
    login_as(@admin_user)
    patch user_path, params: {
      user: {
        first_name: @admin_user.first_name,
        last_name: @admin_user.last_name,
        email_address: @admin_user.email_address,
        role: "super_user"
      }
    }
    assert_redirected_to user_path
    assert_equal "super_user", @admin_user.reload.role
  end

  test "super_user should be able to change their role to user" do
    login_as(@super_user)
    patch user_path, params: {
      user: {
        first_name: @super_user.first_name,
        last_name: @super_user.last_name,
        email_address: @super_user.email_address,
        role: "user"
      }
    }
    assert_redirected_to user_path
    assert_equal "user", @super_user.reload.role
  end

  test "super_user should not be able to change their role to admin" do
    login_as(@super_user)
    patch user_path, params: {
      user: {
        first_name: @super_user.first_name,
        last_name: @super_user.last_name,
        email_address: @super_user.email_address,
        role: "admin"
      }
    }
    assert_redirected_to user_path
    assert_equal "super_user", @super_user.reload.role
    assert_equal "You don't have permission to assign that role.", flash[:alert]
  end

  test "should allow password changes" do
    login_as(@regular_user)
    patch user_path, params: {
      user: {
        first_name: @regular_user.first_name,
        last_name: @regular_user.last_name,
        email_address: @regular_user.email_address,
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }
    assert_redirected_to user_path
    assert @regular_user.reload.authenticate("newpassword123")
  end

  test "should reject mismatched password confirmation" do
    login_as(@regular_user)
    patch user_path, params: {
      user: {
        first_name: @regular_user.first_name,
        last_name: @regular_user.last_name,
        email_address: @regular_user.email_address,
        password: "newpassword123",
        password_confirmation: "different"
      }
    }
    assert_response :unprocessable_entity
  end

  private

  def login_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end
