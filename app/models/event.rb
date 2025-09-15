class Event < ApplicationRecord
  # ----- Enums -----
  # String-backed enum so values are readable in the DB
  enum :status, {
    draft: "draft",
    published: "published",
    canceled: "canceled"
  }

  # ----- Validations -----
  validates :title, :starts_at, :ends_at, :time_zone, :status, presence: true
  validate  :ends_after_starts

  # ----- Associations -----
  has_many :attendances, dependent: :destroy
  has_many :attending_students, -> { where(attendances: { present: true }) }, through: :attendances, source: :student

  # ----- Callbacks -----
  before_validation :set_default_time_zone, :set_default_address
  after_create :send_new_event_notifications
  after_update :send_event_update_notifications

  # ----- Scopes -----
  # Ordering
  scope :ordered,      -> { order(starts_at: :asc) }
  scope :recent_first, -> { order(starts_at: :desc) }

  # Time-based (UTC-aware, not tied to any specific TZ)
  scope :upcoming,        -> { where("ends_at >= ?", Time.current) }
  scope :past,            -> { where("ends_at < ?", Time.current) }
  scope :starting_soon,   ->(hours = 24) { where(starts_at: Time.current..(Time.current + hours.hours)) }
  scope :overlapping,     ->(window_start, window_end) { where("starts_at < ? AND ends_at > ?", window_end, window_start) }
  scope :starting_between, ->(window_start, window_end) { where(starts_at: window_start..window_end) }

  # Status-based
  scope :draft,     -> { where(status: "draft") }
  scope :published, -> { where(status: "published") }
  scope :canceled,  -> { where(status: "canceled") }

  # Special event filtering
  scope :special,   -> { where(special: true) }
  scope :regular,   -> { where(special: false) }

  # Combined scopes for public viewing
  scope :visible_to_public, -> { where(status: [ "published", "canceled" ]) }
  scope :visible_to_admin,  -> { all }

  # ---- Time-based calendar scopes (TZ-aware overlap checks) ----

  # All events that overlap a specific calendar day in a TZ
  scope :on_calendar_day, ->(date = Date.today, tz: "America/Los_Angeles") do
    zone      = ActiveSupport::TimeZone[tz] || Time.zone
    day_start = zone.parse(date.to_s).beginning_of_day.utc
    day_end   = zone.parse(date.to_s).end_of_day.utc
    where("starts_at < ? AND ends_at >= ?", day_end, day_start)
  end

  # All events that overlap the calendar week containing `date` in a TZ
  # Week start follows config.beginning_of_week (default :monday)
  scope :in_week, ->(date = Date.today, tz: "America/Los_Angeles") do
    zone       = ActiveSupport::TimeZone[tz] || Time.zone
    week_start = zone.parse(date.to_s).beginning_of_week.utc
    week_end   = zone.parse(date.to_s).end_of_week.utc
    where("starts_at < ? AND ends_at >= ?", week_end, week_start)
  end

  # All events that overlap the calendar month containing `date` in a TZ
  scope :in_month, ->(date = Date.today, tz: "America/Los_Angeles") do
    zone        = ActiveSupport::TimeZone[tz] || Time.zone
    month_start = zone.parse(date.to_s).beginning_of_month.utc
    month_end   = zone.parse(date.to_s).end_of_month.utc
    where("starts_at < ? AND ends_at >= ?", month_end, month_start)
  end

  # Events happening “now” in a given TZ
  scope :happening_now, ->(tz: "America/Los_Angeles") do
    zone = ActiveSupport::TimeZone[tz] || Time.zone
    now  = zone.now.utc
    where("starts_at <= ? AND ends_at >= ?", now, now)
  end

  # Location filters
  scope :in_city,  ->(city)  { where("LOWER(city) = ?", city.to_s.downcase.strip) }
  scope :in_state, ->(state) { where("LOWER(state) = ?", state.to_s.downcase.strip) }
  scope :in_zip,   ->(zip)   { where(zipcode: zip.to_s.strip) }

  # Simple free-text search across title, description, and venue
  scope :search, ->(term) do
    next all if term.blank?
    pattern = "%#{term.strip.downcase}%"
    where("LOWER(title) LIKE ? OR LOWER(description) LIKE ? OR LOWER(venue) LIKE ?", pattern, pattern, pattern)
  end

  # ----- Instance Methods -----
  def ongoing?(time = Time.current)
    starts_at <= time && ends_at >= time
  end

  def event_datetime
    # Return the starts_at time for display in emails
    starts_at
  end

  def location
    # Build location string from venue and address
    parts = [ venue, address1, city, state ].compact.reject(&:blank?)
    parts.join(", ")
  end

  def special_event?
    # Return the special boolean attribute
    special?
  end

  # Email notification methods
  def send_new_event_notifications
    # Only send notifications for published events
    return unless published?

    NotificationMailer.send_new_event_notifications(self)
  end

  def send_event_update_notifications
    # Only send notifications if the event is published and significant fields changed
    return unless published? && saved_changes.any?

    # Track which fields changed for the notification
    significant_changes = saved_changes.keys & %w[title starts_at ends_at venue address1 city state description]

    if significant_changes.any?
      # If status changed to canceled, send cancellation notification instead
      if saved_changes.key?("status") && status == "canceled"
        NotificationMailer.send_event_cancelled_notifications(self)
      else
        NotificationMailer.send_event_updated_notifications(self, significant_changes)
      end
    end
  end

  private

  def ends_after_starts
    return if ends_at.blank? || starts_at.blank?
    errors.add(:ends_at, "must be after the start time") if ends_at <= starts_at
  end

  def set_default_time_zone
    self.time_zone ||= "America/Los_Angeles"
  end

  def set_default_address
    # Set default venue and address for Lake Elementary School in Oceanside, CA
    self.venue ||= "Lake Elementary School"
    self.address1 ||= "4950 Lake Blvd"
    self.city ||= "Oceanside"
    self.state ||= "CA"
    self.zipcode ||= "92056"
  end
end
