class Donor < ApplicationRecord
  # ----- Enums -----
  enum :donor_type, { individual: "individual", business: "business" }
  enum :privacy_setting, { privacy_public: "public", privacy_private: "private", privacy_anonymous: "anonymous" }

  # ----- Validations -----
  validates :name, :donor_type, :privacy_setting, presence: true
  validates :website_link, format: { with: URI.regexp(%w[http https]) }, allow_blank: true

  # ----- Associations -----
  belongs_to :user, optional: true # Creator (admin who added the donor)
  has_many :donations, dependent: :destroy

  # ----- Active Storage -----
  has_one_attached :photo_or_logo

  # ----- Normalizations -----
  normalizes :website_link, with: ->(url) { url.strip if url.present? }

  # ----- Callbacks -----
  # None for now

  # ----- Scopes -----
  # Ordering
  scope :ordered,           -> { order(:name) }
  scope :recent_created,    -> { order(created_at: :desc) }
  scope :recent_updated,    -> { order(updated_at: :desc) }
  scope :by_total_donated,  -> { joins(:donations).group("donors.id").order("SUM(donations.amount) DESC") }

  # Type-based
  scope :individuals, -> { where(donor_type: "individual") }
  scope :businesses,  -> { where(donor_type: "business") }

  # Privacy-based
  scope :public_donors,    -> { where(privacy_setting: "public") }
  scope :private_donors,   -> { where(privacy_setting: "private") }
  scope :anonymous_donors, -> { where(privacy_setting: "anonymous") }
  scope :visible_donors,   -> { where(privacy_setting: [ "public", "anonymous" ]) }

  # Donation-based
  scope :with_donations,   -> { joins(:donations).distinct }
  scope :without_donations, -> { left_joins(:donations).where(donations: { id: nil }) }

  # Search
  scope :search, ->(term) do
    next all if term.blank?
    pattern = "%#{term.to_s.downcase.strip}%"
    left_joins(:donations).where(
      "LOWER(donors.name) LIKE :term OR LOWER(donations.donation_type) LIKE :term",
      term: pattern
    ).distinct
  end

  # ----- Instance Methods -----
  def display_name
    if privacy_anonymous?
      "Anonymous Donor"
    else
      name
    end
  end

  def has_logo_or_photo?
    photo_or_logo.attached?
  end

  def total_monetary_donated
    donations.with_monetary_value.sum(:amount) || 0
  end

  def formatted_total_donated
    return "Amount not disclosed" if privacy_private?

    monetary_total = total_monetary_donated
    non_monetary_count = donations.non_monetary.count

    if monetary_total > 0 && non_monetary_count > 0
      "$#{'%.2f' % monetary_total.to_f} + #{non_monetary_count} non-monetary"
    elsif monetary_total > 0
      "$#{'%.2f' % monetary_total.to_f}"
    elsif non_monetary_count > 0
      "#{non_monetary_count} non-monetary donation#{'s' if non_monetary_count != 1}"
    else
      "No donations recorded"
    end
  end

  def has_monetary_donations?
    donations.with_monetary_value.any?
  end

  def has_non_monetary_donations?
    donations.non_monetary.any?
  end

  def donation_count
    donations.count
  end

  def latest_donation
    donations.ordered.first
  end

  def display_for_public?
    privacy_public? || privacy_anonymous?
  end

  # Alias method for backward compatibility
  def publicly_visible?
    privacy_public? || privacy_anonymous?
  end
end
