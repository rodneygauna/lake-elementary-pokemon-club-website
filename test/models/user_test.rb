require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @admin_user = users(:admin_user)
    @super_user = users(:super_user)
    @regular_user = users(:regular_user)
    @valid_attributes = {
      first_name: "Test",
      last_name: "User",
      email_address: "test@example.com",
      password: "password123",
      role: "user",
      status: "active"
    }
  end

  # Test validations
  test "should be valid with valid attributes" do
    user = User.new(@valid_attributes)
    assert user.valid?
  end

  test "should require email_address" do
    user = User.new(@valid_attributes.except(:email_address))
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "should require first_name" do
    user = User.new(@valid_attributes.except(:first_name))
    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "should require last_name" do
    user = User.new(@valid_attributes.except(:last_name))
    assert_not user.valid?
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "should require unique email" do
    user = User.new(@valid_attributes.merge(email_address: @admin_user.email_address))
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "should validate email format" do
    user = User.new(@valid_attributes.merge(email_address: "invalid-email"))
    assert_not user.valid?
    assert_includes user.errors[:email_address], "is invalid"
  end

  test "should validate phone number format" do
    user = User.new(@valid_attributes.merge(phone_number: "invalid-phone"))
    assert_not user.valid?
    assert_includes user.errors[:phone_number], "is invalid"
  end

  # Test enums
  test "should have role enum" do
    assert_equal "admin", @admin_user.role
    assert_equal "super_user", @super_user.role
    assert_equal "user", @regular_user.role
    assert @admin_user.admin?
    assert @super_user.super_user?
    assert @regular_user.user?
  end

  test "should have status enum" do
    assert_equal "active", @admin_user.status
    assert @admin_user.active?

    inactive_user = users(:inactive_user)
    assert_equal "inactive", inactive_user.status
    assert inactive_user.inactive?
  end

  # Test associations
  test "should have many sessions" do
    assert_respond_to @admin_user, :sessions
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @admin_user.sessions
  end

  test "should have many students through user_students" do
    assert_respond_to @admin_user, :students
    assert_respond_to @admin_user, :user_students
  end

  test "should have many marked_attendances" do
    assert_respond_to @admin_user, :marked_attendances
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @admin_user.marked_attendances
  end

  # Test normalization
  test "should normalize email to lowercase" do
    user = User.create!(@valid_attributes.merge(email_address: "TEST@EXAMPLE.COM"))
    assert_equal "test@example.com", user.email_address
  end

  # Test scopes
  test "admin scope should return admin users" do
    admins = User.admin
    assert_includes admins, @admin_user
    assert_not_includes admins, @regular_user
  end

  test "active scope should return active users" do
    active_users = User.active
    assert_includes active_users, @admin_user
    assert_includes active_users, @regular_user
    assert_not_includes active_users, users(:inactive_user)
  end

  # Test instance methods
  test "full_name should combine first and last name" do
    assert_equal "Admin User", @admin_user.full_name
    assert_equal "John Doe", @regular_user.full_name
  end

  test "initials should return first letters of names" do
    assert_equal "AU", @admin_user.initials
    assert_equal "JD", @regular_user.initials
  end

  # Test password authentication
  test "should authenticate with correct password" do
    user = User.create!(@valid_attributes)
    assert user.authenticate("password123")
    assert_not user.authenticate("wrong_password")
  end

  # Test role assignment permissions
  test "admin should be able to assign all roles" do
    expected_roles = %w[user super_user admin]
    assert_equal expected_roles, @admin_user.can_assign_roles

    expected_roles.each do |role|
      assert @admin_user.can_assign_role?(role), "Admin should be able to assign #{role} role"
    end
  end

  test "super_user should be able to assign user and super_user roles only" do
    expected_roles = %w[user super_user]
    assert_equal expected_roles, @super_user.can_assign_roles

    assert @super_user.can_assign_role?("user")
    assert @super_user.can_assign_role?("super_user")
    assert_not @super_user.can_assign_role?("admin"), "Super user should not be able to assign admin role"
  end

  test "regular user should not be able to assign any roles" do
    assert_equal [], @regular_user.can_assign_roles

    %w[user super_user admin].each do |role|
      assert_not @regular_user.can_assign_role?(role), "Regular user should not be able to assign #{role} role"
    end
  end

  # Test user editing permissions
  test "admin should be able to edit all users" do
    assert @admin_user.can_edit_user?(@regular_user)
    assert @admin_user.can_edit_user?(@super_user)
    assert @admin_user.can_edit_user?(@admin_user)
  end

  test "super_user should be able to edit users and super_users but not admins" do
    assert @super_user.can_edit_user?(@regular_user)
    assert @super_user.can_edit_user?(@super_user)
    assert_not @super_user.can_edit_user?(@admin_user), "Super user should not be able to edit admin"
  end

  test "regular user should not be able to edit any users" do
    assert_not @regular_user.can_edit_user?(@regular_user)
    assert_not @regular_user.can_edit_user?(@super_user)
    assert_not @regular_user.can_edit_user?(@admin_user)
  end

  # Test role display names
  test "should return correct role display names" do
    assert_equal "Administrator", @admin_user.role_display_name
    assert_equal "Super User", @super_user.role_display_name
    assert_equal "User", @regular_user.role_display_name
  end

  # Test admin_level? helper
  test "admin_level should return true for admin and super_user" do
    assert @admin_user.admin_level?
    assert @super_user.admin_level?
    assert_not @regular_user.admin_level?
  end

  # Test can_delete? permissions
  test "only admins should be able to delete" do
    assert @admin_user.can_delete?
    assert_not @super_user.can_delete?
    assert_not @regular_user.can_delete?
  end

  # Test can_manage_users? permissions
  test "admin_level users should be able to manage users" do
    assert @admin_user.can_manage_users?
    assert @super_user.can_manage_users?
    assert_not @regular_user.can_manage_users?
  end
end
