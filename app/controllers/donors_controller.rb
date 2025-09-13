class DonorsController < ApplicationController
  allow_unauthenticated_access

  def public_index
    @individual_donors = Donor.individuals.visible_donors.ordered
    @business_donors = Donor.businesses.visible_donors.ordered
  end
end
