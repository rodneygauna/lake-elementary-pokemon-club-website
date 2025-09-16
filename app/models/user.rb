class User < ApplicationRecord
  # ----- Enums -----
  enum :role, { user: "user", super_user: "super_user", admin: "admin" }
  enum :status, { active: "active", inactive: "inactive", suspended: "suspended" }

  # ----- Validations -----
  validates :email_address, :first_name, :last_name, :role, :status, presence: true
  validates :email_address, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, format: { with: /\A\+?[0-9\s\-\(\)]*\z/ }, allow_blank: true

  # ----- Associations -----
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :user_students, dependent: :destroy
  has_many :students, through: :user_students
  has_many :marked_attendances, class_name: "Attendance", foreign_key: "marked_by_id", dependent: :destroy
  has_many :email_subscriptions, dependent: :destroy

  # ---- Normalizations -----
  # Normalize email before validation
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # ----- Callbacks -----
  after_create :create_default_subscriptions!
  after_create :send_welcome_email
  after_update :send_profile_update_notification

  # ----- Scopes -----
  # Ordering
  scope :ordered,      -> { order(created_at: :asc) }
  scope :recent_created, -> { order(created_at: :desc) }
  scope :recent_updated, -> { order(updated_at: :desc) }
  scope :by_last_name, -> { order(last_name: :asc, first_name: :asc) }

  # Role-based
  scope :admins,      -> { where(role: "admin") }
  scope :super_users, -> { where(role: "super_user") }
  scope :users,       -> { where(role: "user") }
  scope :admin_level, -> { where(role: [ "admin", "super_user" ]) }
  scope :parent_eligible, -> { where(role: [ "user", "super_user" ]) }

  # Status-based
  scope :active,    -> { where(status: "active") }
  scope :inactive,  -> { where(status: "inactive") }
  scope :suspended, -> { where(status: "suspended") }

  # Simiple free-text search across first_name, last_name, and email_address
  scope :search, ->(term) do
    next all if term.blank?
    pattern = "%#{term.to_s.downcase.strip}%"
    where("LOWER(first_name) LIKE :term OR LOWER(last_name) LIKE :term OR LOWER(email_address) LIKE :term", term: pattern)
  end

  # ----- Instance Methods -----
  def full_name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name.first}#{last_name.first}".upcase
  end

  def active_for_authentication?
    super && status == "active"
  end

  def inactive_message
    if status == "inactive"
      "Your account is inactive. Please contact support."
    elsif status == "suspended"
      "Your account has been suspended. Please contact support."
    else
      super
    end
  end

  # Role-based permission helpers
  def admin_level?
    admin? || super_user?
  end

  def can_delete?
    admin?
  end

  def can_manage_users?
    admin_level?
  end

  def can_edit_user?(target_user)
    return false unless admin_level?
    return true if admin?
    # Super users can only edit regular users and other super users, not admins
    !target_user.admin?
  end

  def can_assign_roles
    if admin?
      %w[user super_user admin]
    elsif super_user?
      %w[user super_user]
    else
      []
    end
  end

  def can_assign_role?(role_to_assign)
    can_assign_roles.include?(role_to_assign.to_s)
  end

  def role_display_name
    case role
    when "admin"
      "Administrator"
    when "super_user"
      "Super User"
    when "user"
      "User"
    else
      role.humanize
    end
  end

  # Email subscription methods
  def subscribed_to?(subscription_type)
    email_subscriptions.enabled.exists?(subscription_type: subscription_type)
  end

  def subscription_for(subscription_type)
    email_subscriptions.find_by(subscription_type: subscription_type)
  end

  def enable_subscription(subscription_type)
    subscription = email_subscriptions.find_or_initialize_by(subscription_type: subscription_type)
    subscription.update(enabled: true)
  end

  def disable_subscription(subscription_type)
    subscription = email_subscriptions.find_by(subscription_type: subscription_type)
    subscription&.update(enabled: false)
  end

  def create_default_subscriptions!
    EmailSubscription.default_subscriptions.each do |subscription_type|
      email_subscriptions.find_or_create_by(subscription_type: subscription_type) do |subscription|
        subscription.enabled = true
      end
    end
  end

  # ----- Welcome Email Support -----
  # Accessor for temporary password to send in welcome email
  attr_accessor :temporary_password_for_email

  private
  # ----- Private Methods -----

  def send_welcome_email
    # Only send welcome email if temporary password was provided
    return unless temporary_password_for_email.present?

    # Determine if this was created by an admin
    created_by_admin = false
    admin_user = nil

    # Check if Current has a session and user (admin creating the account)
    if defined?(Current) && Current.session && Current.user
      current_user = Current.user
      if current_user.admin_level?
        created_by_admin = true
        admin_user = current_user
      end
    end

    # Send the welcome email (no subscription check needed - always send)
    begin
      email = NotificationMailer.new_user_welcome(
        self,
        temporary_password_for_email,
        created_by_admin,
        admin_user
      )

      # Use deliver_now in test environment, deliver_later in others
      if Rails.env.test?
        email.deliver_now
      else
        email.deliver_later
      end
    rescue => e
      Rails.logger.error "Failed to send welcome email for user #{id}: #{e.message}"
    end
  end

  def send_profile_update_notification
    # Only send notification if there were actual changes and user is subscribed
    return unless saved_changes.any?
    return unless subscribed_to?(:user_profile_updated)

    # Get the changed fields (excluding timestamps)
    changed_fields = saved_changes.keys.reject { |field| field.in?(%w[updated_at created_at]) }
    return if changed_fields.empty?

    # Determine if this was changed by an admin
    # In a real application, this would be tracked through the controller or session
    # For now, we'll assume any change to role/status by someone other than the user is admin
    changed_by_admin = false
    admin_user = nil

    # Check if Current has a session and user
    if defined?(Current) && Current.session && Current.user
      current_user = Current.user
      if current_user != self && (current_user.admin_level? || current_user.super_user?)
        changed_by_admin = true
        admin_user = current_user
      end
    end

    # Send the notification
    begin
      NotificationMailer.user_profile_updated(
        self,
        changed_fields,
        changed_by_admin,
        admin_user
      ).deliver_later
    rescue => e
      Rails.logger.error "Failed to send user profile update notification for user #{id}: #{e.message}"
    end
  end
end
