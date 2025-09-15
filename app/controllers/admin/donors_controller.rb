class Admin::DonorsController < ApplicationController
  before_action :require_authentication
  before_action :require_admin_level
  before_action :require_admin, only: [ :destroy ]
  before_action :set_donor, only: %i[ show edit update destroy ]

  # GET /donors or /donors.json
  def index
    @donors = Donor.ordered

    # Filter by donor type if specified
    @donors = @donors.where(donor_type: params[:donor_type]) if params[:donor_type].present?

    # Search functionality
    @donors = @donors.search(params[:search]) if params[:search].present?
  end

  # GET /donors/1 or /donors/1.json
  def show
  end

  # GET /donors/new
  def new
    @donor = Donor.new
  end

  # GET /donors/1/edit
  def edit
  end

  # POST /donors or /donors.json
  def create
    @donor = Donor.new(donor_params)
    @donor.user = current_user # Set creator

    if @donor.save
      redirect_to admin_donor_path(@donor), notice: "Donor was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /donors/1 or /donors/1.json
  def update
    if @donor.update(donor_params)
      redirect_to admin_donor_path(@donor), notice: "Donor was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /donors/1 or /donors/1.json
  def destroy
    @donor.destroy!
    redirect_to admin_donors_path, notice: "Donor was successfully deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_donor
      @donor = Donor.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def donor_params
      params.require(:donor).permit(:name, :donor_type, :privacy_setting, :website_link, :photo_or_logo)
    end
end
