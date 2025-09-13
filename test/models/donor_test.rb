require "test_helper"

class DonorTest < ActiveSupport::TestCase
  def setup
    @individual_donor = donors(:individual_donor)
    @business_donor = donors(:business_donor)
    @private_donor = donors(:private_donor)
    @valid_attributes = {
      name: "Test Donor",
      donor_type: "individual",
      privacy_setting: "public"
    }
  end

  # Test validations
  test "should be valid with valid attributes" do
    donor = Donor.new(@valid_attributes)
    assert donor.valid?
  end

  test "should require name" do
    donor = Donor.new(@valid_attributes.except(:name))
    assert_not donor.valid?
    assert_includes donor.errors[:name], "can't be blank"
  end

  test "should require donor_type" do
    donor = Donor.new(@valid_attributes.except(:donor_type))
    assert_not donor.valid?
    assert_includes donor.errors[:donor_type], "can't be blank"
  end

  test "should require privacy_setting" do
    donor = Donor.new(@valid_attributes.except(:privacy_setting))
    assert_not donor.valid?
    assert_includes donor.errors[:privacy_setting], "can't be blank"
  end

  test "should validate website_link format" do
    donor = Donor.new(@valid_attributes.merge(website_link: "invalid-url"))
    assert_not donor.valid?
    assert_includes donor.errors[:website_link], "is invalid"

    donor.website_link = "https://example.com"
    assert donor.valid?
  end

  # Test enums
  test "should have donor_type enum" do
    assert_equal "individual", @individual_donor.donor_type
    assert_equal "business", @business_donor.donor_type
    assert @individual_donor.individual?
    assert @business_donor.business?
  end

  test "should have privacy_setting enum" do
    # Test enum method calls
    assert @individual_donor.privacy_public?
    assert @business_donor.privacy_private?

    # Test enum values are stored as strings
    assert_includes Donor.privacy_settings.values, "public"
    assert_includes Donor.privacy_settings.values, "private"
    assert_includes Donor.privacy_settings.values, "anonymous"

    # Test enum transitions
    @individual_donor.privacy_anonymous!
    assert @individual_donor.privacy_anonymous?
  end

  # Test associations
  test "should have many donations" do
    assert_respond_to @individual_donor, :donations
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @individual_donor.donations
  end

  test "should belong to user optionally" do
    donor = Donor.new(@valid_attributes)
    assert donor.valid?

    donor.user = users(:admin_user)
    assert donor.valid?
  end

  test "should have attached photo_or_logo" do
    assert_respond_to @individual_donor, :photo_or_logo
  end

  # Test scopes
  test "individuals scope should return individual donors" do
    individuals = Donor.individuals
    assert_includes individuals, @individual_donor
    assert_not_includes individuals, @business_donor
  end

  test "businesses scope should return business donors" do
    businesses = Donor.businesses
    assert_includes businesses, @business_donor
    assert_not_includes businesses, @individual_donor
  end

  test "public_donors scope should return public donors" do
    public_donors = Donor.public_donors
    assert_includes public_donors, @individual_donor
    assert_not_includes public_donors, @private_donor
  end

  test "private_donors scope should return private donors" do
    private_donors = Donor.private_donors
    assert_includes private_donors, @private_donor
    assert_not_includes private_donors, @individual_donor
  end

  test "visible_donors scope should return public and anonymous donors" do
    # Create an anonymous donor for testing
    anonymous_donor = Donor.create!(@valid_attributes.merge(
      name: "Anonymous Test",
      privacy_setting: "anonymous"
    ))

    visible_donors = Donor.visible_donors
    assert_includes visible_donors, @individual_donor # public
    assert_includes visible_donors, anonymous_donor # anonymous
    assert_not_includes visible_donors, @private_donor # private
  end

  test "search scope should find donors by name" do
    results = Donor.search("John")
    assert_includes results, @individual_donor
  end

  # Test instance methods
  test "display_name should return name for public donors" do
    assert_equal @individual_donor.name, @individual_donor.display_name
  end

  test "display_name should return Anonymous Donor for anonymous donors" do
    anonymous_donor = Donor.create!(@valid_attributes.merge(
      name: "Secret Donor",
      privacy_setting: "anonymous"
    ))
    assert_equal "Anonymous Donor", anonymous_donor.display_name
  end

  test "has_logo_or_photo should return false when no attachment" do
    assert_not @individual_donor.has_logo_or_photo?
  end

  test "total_monetary_donated should return sum of monetary donations" do
    # Uses existing fixtures with donations
    total = @individual_donor.total_monetary_donated
    assert_kind_of Numeric, total
    assert total >= 0
  end

  test "formatted_total_donated should return formatted string" do
    formatted = @individual_donor.formatted_total_donated
    assert_kind_of String, formatted
    assert_not formatted.blank?
  end

  test "formatted_total_donated should not disclose amount for private donors" do
    formatted = @private_donor.formatted_total_donated
    assert_equal "Amount not disclosed", formatted
  end

  test "has_monetary_donations should return boolean" do
    result = @individual_donor.has_monetary_donations?
    assert [ true, false ].include?(result)
  end

  test "has_non_monetary_donations should return boolean" do
    result = @individual_donor.has_non_monetary_donations?
    assert [ true, false ].include?(result)
  end

  test "donation_count should return number of donations" do
    count = @individual_donor.donation_count
    assert_kind_of Integer, count
    assert count >= 0
  end

  test "display_for_public should return true for public and anonymous donors" do
    assert @individual_donor.display_for_public? # public
    assert_not @private_donor.display_for_public? # private

    anonymous_donor = Donor.create!(@valid_attributes.merge(
      name: "Anonymous Test",
      privacy_setting: "anonymous"
    ))
    assert anonymous_donor.display_for_public? # anonymous
  end

  test "publicly_visible should be alias for display_for_public" do
    assert_equal @individual_donor.display_for_public?, @individual_donor.publicly_visible?
  end

  # Test normalizations
  test "should normalize website_link" do
    donor = Donor.create!(@valid_attributes.merge(website_link: "  https://example.com  "))
    assert_equal "https://example.com", donor.website_link
  end
end
