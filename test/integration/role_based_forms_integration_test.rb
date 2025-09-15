require "test_helper"

class RoleBasedFormsIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = users(:admin_user)
    @super_user = users(:super_user)
    @regular_user = users(:regular_user)
  end

  test "regular user profile edit should not show role selection" do
    login_as(@regular_user)
    get edit_user_path

    assert_response :success
    # Should show read-only role display
    assert_includes response.body, "Current Role"
    assert_includes response.body, "Contact an administrator"
    # Should not show role dropdown
    assert_not_includes response.body, 'name="user[role]"'
  end

  test "admin profile edit should show all role options" do
    login_as(@admin_user)
    get edit_user_path

    assert_response :success
    # Should show role dropdown
    assert_includes response.body, 'name="user[role]"'
    # Should include all role options
    assert_includes response.body, 'value="admin"'
    assert_includes response.body, 'value="super_user"'
    assert_includes response.body, 'value="user"'
    # Should show admin help text
    assert_includes response.body, "Administrators can assign any role"
  end

  test "super_user profile edit should show limited role options" do
    login_as(@super_user)
    get edit_user_path

    assert_response :success
    # Should show role dropdown
    assert_includes response.body, 'name="user[role]"'
    # Should include limited role options
    assert_not_includes response.body, 'value="admin"'
    assert_includes response.body, 'value="super_user"'
    assert_includes response.body, 'value="user"'
    # Should show super user help text
    assert_includes response.body, "Super Users can assign User and Super User roles only"
  end

  test "admin new user form should show all role options" do
    login_as(@admin_user)
    get new_admin_user_path

    assert_response :success
    # Should show all role options
    assert_includes response.body, 'value="admin"'
    assert_includes response.body, 'value="super_user"'
    assert_includes response.body, 'value="user"'
    # Should show admin help text
    assert_includes response.body, "Super Users can manage content but cannot delete. Administrators have full access."
  end

  test "super_user new user form should show limited role options" do
    login_as(@super_user)
    get new_admin_user_path

    assert_response :success
    # Should show limited role options
    assert_not_includes response.body, 'value="admin"'
    assert_includes response.body, 'value="super_user"'
    assert_includes response.body, 'value="user"'
    # Should show super user help text
    assert_includes response.body, "You can assign User and Super User roles"
  end

  test "admin edit user form should show all role options" do
    login_as(@admin_user)
    get edit_admin_user_path(@regular_user)

    assert_response :success
    # Should show all role options
    assert_includes response.body, 'value="admin"'
    assert_includes response.body, 'value="super_user"'
    assert_includes response.body, 'value="user"'
  end

  test "super_user edit user form should show limited role options" do
    login_as(@super_user)
    get edit_admin_user_path(@regular_user)

    assert_response :success
    # Should show limited role options
    assert_not_includes response.body, 'value="admin"'
    assert_includes response.body, 'value="super_user"'
    assert_includes response.body, 'value="user"'
  end

  test "role badges should display correctly in profile" do
    # Test admin badge
    login_as(@admin_user)
    get user_path
    assert_includes response.body, "bg-warning"
    assert_includes response.body, "Administrator"

    # Test super user badge
    login_as(@super_user)
    get user_path
    assert_includes response.body, "bg-success"
    assert_includes response.body, "Super User"

    # Test regular user badge
    login_as(@regular_user)
    get user_path
    assert_includes response.body, "bg-light"
    assert_includes response.body, "User"
  end

  test "admin user list should show delete buttons for admin only" do
    login_as(@admin_user)
    get admin_users_path

    assert_response :success
    # Should show delete buttons since admin can delete
    assert_includes response.body, "btn-outline-danger"
    assert_includes response.body, "fa-trash"
  end

  test "super_user should not see delete buttons in admin interface" do
    login_as(@super_user)
    get admin_users_path

    assert_response :success
    # Should not show delete buttons since super_user cannot delete
    assert_not_includes response.body, "btn-outline-danger"
  end

  test "role permissions should be enforced in forms" do
    # Admin creating admin user should work
    login_as(@admin_user)
    post admin_users_path, params: {
      user: {
        first_name: "Test",
        last_name: "Admin",
        email_address: "testadmin@test.com",
        role: "admin",
        status: "active"
      }
    }
    assert_response :redirect
    assert User.find_by(email_address: "testadmin@test.com").admin?

    # Super user creating admin should fail
    login_as(@super_user)
    post admin_users_path, params: {
      user: {
        first_name: "Test",
        last_name: "Admin2",
        email_address: "testadmin2@test.com",
        role: "admin",
        status: "active"
      }
    }
    assert_response :unprocessable_entity
    assert_nil User.find_by(email_address: "testadmin2@test.com")
  end

  private

  def login_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end
