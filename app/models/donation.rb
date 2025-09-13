class Donation < ApplicationRecord
  # ----- Enums -----
  enum :value_type, {
    monetary: "monetary",     # Cash donations - requires amount
    material: "material",     # Physical items - no dollar amount needed
    service: "service"        # Time, expertise, services - no dollar amount needed
  }

  # ----- Validations -----
  validates :donation_type, presence: true
  validates :donation_date, presence: true
  validates :value_type, presence: true

  # Only require amount for monetary donations
  validates :amount, presence: true, numericality: { greater_than: 0 }, if: :monetary?

  # ----- Associations -----
  belongs_to :donor

  # ----- Normalizations -----
  normalizes :donation_type, with: ->(type) { type.strip.titleize if type.present? }

  # ----- Callbacks -----
  before_validation :set_default_date, on: :create

  # ----- Scopes -----
  # Ordering
  scope :ordered,           -> { order(donation_date: :desc, created_at: :desc) }
  scope :recent_created,    -> { order(created_at: :desc) }
  scope :recent_updated,    -> { order(updated_at: :desc) }
  scope :by_amount,         -> { order(amount: :desc) }

  # Date-based
  scope :recent,      ->(days = 30) { where(donation_date: days.days.ago..Date.current) }
  scope :this_year,   -> { where(donation_date: Date.current.beginning_of_year..Date.current.end_of_year) }
  scope :last_year,   -> { where(donation_date: 1.year.ago.beginning_of_year..1.year.ago.end_of_year) }

  # Amount-based (only for monetary donations)
  scope :large_donations, ->(threshold = 100) { monetary.where("amount >= ?", threshold) }

  # Value type based
  scope :with_monetary_value, -> { monetary.where.not(amount: nil) }
  scope :non_monetary, -> { where(value_type: [ "material", "service" ]) }

  # ----- Instance Methods -----
  def formatted_amount
    case value_type
    when "monetary"
      return "Not specified" if amount.blank?
      "$#{amount.to_f.round(2)}"
    when "material"
      "Material donation"
    when "service"
      "Service donation"
    else
      "Donation"
    end
  end

  def has_monetary_value?
    monetary? && amount.present?
  end

  def display_value_type
    case value_type
    when "monetary"
      "💰 Monetary"
    when "material"
      "📦 Materials"
    when "service"
      "🤝 Services"
    else
      "💝 Donation"
    end
  end

  def display_date
    donation_date&.strftime("%B %d, %Y") || "Date not set"
  end

  private

  def set_default_date
    self.donation_date ||= Date.current
  end
end
