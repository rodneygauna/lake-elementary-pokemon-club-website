class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    # Get public donors for the carousel
    @business_donors = Donor.businesses.public_donors.limit(6)
    @individual_donors = Donor.individuals.public_donors.limit(6)

    # Get the next upcoming event
    @next_event = Event.published.upcoming.order(:starts_at).first
  end
end
