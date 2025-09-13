class Admin::DonationsController < ApplicationController
  include Authentication

  before_action :require_admin_access
  before_action :set_donor
  before_action :set_donation, only: [ :show, :edit, :update, :destroy ]

  # GET /admin/donors/:donor_id/donations
  def index
    @donations = @donor.donations.ordered
  end

  # GET /admin/donors/:donor_id/donations/:id
  def show
  end

  # GET /admin/donors/:donor_id/donations/new
  def new
    @donation = @donor.donations.build
    @donation.donation_date = Date.current
  end

  # GET /admin/donors/:donor_id/donations/:id/edit
  def edit
  end

  # POST /admin/donors/:donor_id/donations
  def create
    @donation = @donor.donations.build(donation_params)

    if @donation.save
      redirect_to admin_donor_path(@donor), notice: "Donation was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/donors/:donor_id/donations/:id
  def update
    if @donation.update(donation_params)
      redirect_to admin_donor_path(@donor), notice: "Donation was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end  # DELETE /admin/donors/:donor_id/donations/:id
  def destroy
    @donation.destroy!
    redirect_to admin_donor_path(@donor), notice: "Donation was successfully deleted."
  end

  private

  def set_donor
    @donor = Donor.find(params[:donor_id])
  end

  def set_donation
    @donation = @donor.donations.find(params[:id])
  end

  def donation_params
    params.require(:donation).permit(:amount, :donation_type, :value_type, :donation_date, :notes)
  end

  def require_admin_access
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
end
