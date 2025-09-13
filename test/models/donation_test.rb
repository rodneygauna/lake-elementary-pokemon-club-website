require "test_helper"

class DonationTest < ActiveSupport::TestCase
  def setup
    @monetary_donation = donations(:monetary_donation)
    @material_donation = donations(:material_donation)
    @service_donation = donations(:service_donation)
    @donor = donors(:individual_donor)
    @valid_attributes = {
      donor: @donor,
      donation_type: "General Support",
      donation_date: Date.current,
      value_type: "monetary",
      amount: 50.00
    }
  end

  # Test validations
  test "should be valid with valid attributes" do
    donation = Donation.new(@valid_attributes)
    assert donation.valid?
  end

  test "should require donation_type" do
    donation = Donation.new(@valid_attributes.except(:donation_type))
    assert_not donation.valid?
    assert_includes donation.errors[:donation_type], "can't be blank"
  end

  test "should require donation_date" do
    donation = Donation.new(@valid_attributes.except(:donation_date))
    # Skip the before_validation callback by setting date to nil after construction
    donation.define_singleton_method(:set_default_date) { self.donation_date = nil }
    assert_not donation.valid?
    assert_includes donation.errors[:donation_date], "can't be blank"
  end

  test "should require value_type" do
    donation = Donation.new(@valid_attributes.except(:value_type))
    assert_not donation.valid?
    assert_includes donation.errors[:value_type], "can't be blank"
  end

  test "should require amount for monetary donations" do
    donation = Donation.new(@valid_attributes.merge(amount: nil))
    assert_not donation.valid?
    assert_includes donation.errors[:amount], "can't be blank"
  end

  test "should not require amount for material donations" do
    donation = Donation.new(@valid_attributes.merge(value_type: "material", amount: nil))
    assert donation.valid?
  end

  test "should not require amount for service donations" do
    donation = Donation.new(@valid_attributes.merge(value_type: "service", amount: nil))
    assert donation.valid?
  end

  test "should validate amount is greater than zero for monetary donations" do
    donation = Donation.new(@valid_attributes.merge(amount: 0))
    assert_not donation.valid?
    assert_includes donation.errors[:amount], "must be greater than 0"

    donation.amount = -10
    assert_not donation.valid?
    assert_includes donation.errors[:amount], "must be greater than 0"

    donation.amount = 10
    assert donation.valid?
  end

  # Test enums
  test "should have value_type enum" do
    assert_equal "monetary", @monetary_donation.value_type
    assert_equal "material", @material_donation.value_type
    assert_equal "service", @service_donation.value_type

    assert @monetary_donation.monetary?
    assert @material_donation.material?
    assert @service_donation.service?
  end

  # Test associations
  test "should belong to donor" do
    assert_respond_to @monetary_donation, :donor
    assert_equal @donor, @monetary_donation.donor
  end

  test "should require donor" do
    donation = Donation.new(@valid_attributes.except(:donor))
    assert_not donation.valid?
    assert_includes donation.errors[:donor], "must exist"
  end

  # Test scopes
  test "ordered scope should order by donation_date desc then created_at desc" do
    # Create donations with different dates
    Donation.create!(@valid_attributes.merge(donation_date: 1.week.ago))
    new_donation = Donation.create!(@valid_attributes.merge(donation_date: Date.current))

    ordered_donations = Donation.ordered
    assert_equal new_donation, ordered_donations.first
  end

  test "recent scope should return donations from last 30 days" do
    old_donation = Donation.create!(@valid_attributes.merge(donation_date: 2.months.ago))
    recent_donation = Donation.create!(@valid_attributes.merge(donation_date: 1.week.ago))

    recent_donations = Donation.recent
    assert_includes recent_donations, recent_donation
    assert_not_includes recent_donations, old_donation
  end

  test "this_year scope should return donations from current year" do
    this_year_donation = Donation.create!(@valid_attributes.merge(donation_date: Date.current.beginning_of_year))
    last_year_donation = Donation.create!(@valid_attributes.merge(donation_date: 1.year.ago))

    this_year_donations = Donation.this_year
    assert_includes this_year_donations, this_year_donation
    assert_not_includes this_year_donations, last_year_donation
  end

  test "with_monetary_value scope should return monetary donations with amount" do
    monetary_donations = Donation.with_monetary_value
    assert_includes monetary_donations, @monetary_donation
    assert_not_includes monetary_donations, @material_donation
    assert_not_includes monetary_donations, @service_donation
  end

  test "non_monetary scope should return material and service donations" do
    non_monetary = Donation.non_monetary
    assert_includes non_monetary, @material_donation
    assert_includes non_monetary, @service_donation
    assert_not_includes non_monetary, @monetary_donation
  end

  test "large_donations scope should return donations above threshold" do
    large_donation = Donation.create!(@valid_attributes.merge(amount: 150))
    small_donation = Donation.create!(@valid_attributes.merge(amount: 25))

    large_donations = Donation.large_donations(100)
    assert_includes large_donations, large_donation
    assert_not_includes large_donations, small_donation
  end

  # Test callbacks
  test "should set default donation_date on create" do
    donation = Donation.new(@valid_attributes.except(:donation_date))
    donation.save!
    assert_equal Date.current, donation.donation_date
  end

  test "should not override provided donation_date" do
    custom_date = 1.week.ago.to_date
    donation = Donation.new(@valid_attributes.merge(donation_date: custom_date))
    donation.save!
    assert_equal custom_date, donation.donation_date
  end

  # Test instance methods
  test "formatted_amount should return formatted monetary amount" do
    assert_equal "$50.0", @monetary_donation.formatted_amount
  end

  test "formatted_amount should return descriptive text for non-monetary" do
    assert_equal "Material donation", @material_donation.formatted_amount
    assert_equal "Service donation", @service_donation.formatted_amount
  end

  test "formatted_amount should handle missing amount for monetary donations" do
    monetary_no_amount = Donation.create!(@valid_attributes.merge(value_type: "material"))
    monetary_no_amount.update_column(:value_type, "monetary") # Bypass validation
    monetary_no_amount.update_column(:amount, nil)
    assert_equal "Not specified", monetary_no_amount.formatted_amount
  end

  test "has_monetary_value should return true for monetary donations with amount" do
    assert @monetary_donation.has_monetary_value?
    assert_not @material_donation.has_monetary_value?
    assert_not @service_donation.has_monetary_value?
  end

  test "display_value_type should return emoji formatted type" do
    assert_equal "💰 Monetary", @monetary_donation.display_value_type
    assert_equal "📦 Materials", @material_donation.display_value_type
    assert_equal "🤝 Services", @service_donation.display_value_type
  end

  test "display_date should return formatted date" do
    expected_format = @monetary_donation.donation_date.strftime("%B %d, %Y")
    assert_equal expected_format, @monetary_donation.display_date
  end

  test "display_date should handle nil donation_date" do
    donation = Donation.new(@valid_attributes)
    donation.donation_date = nil
    assert_equal "Date not set", donation.display_date
  end

  # Test normalizations
  test "should normalize donation_type" do
    donation = Donation.create!(@valid_attributes.merge(donation_type: "  general support  "))
    assert_equal "General Support", donation.donation_type
  end
end
