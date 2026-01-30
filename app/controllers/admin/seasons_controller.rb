class Admin::SeasonsController < ApplicationController
  before_action :require_authentication
  before_action :require_admin_level
  before_action :require_admin, only: [ :destroy ]
  before_action :set_season, only: %i[ show edit update destroy bulk_enroll ]

  # GET /admin/seasons
  def index
    # By default, show only active seasons unless explicitly requested to show all
    if params[:show_inactive] == "true"
      @seasons = Season.ordered
      @show_inactive = true
    else
      @seasons = Season.active.ordered
      @show_inactive = false
    end
  end

  # GET /admin/seasons/1
  def show
    # Load students enrolled in this season
    @students = @season.students.active.by_last_name
  end

  # GET /admin/seasons/new
  def new
    @season = Season.new
  end

  # GET /admin/seasons/1/edit
  def edit
  end

  # POST /admin/seasons
  def create
    @season = Season.new(season_params)

    if @season.save
      redirect_to admin_season_path(@season), notice: "Season was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/seasons/1
  def update
    if @season.update(season_params)
      redirect_to admin_season_path(@season), notice: "Season was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/seasons/1
  def destroy
    @season.destroy!
    redirect_to admin_seasons_path, notice: "Season was successfully deleted."
  end

  # POST /admin/seasons/1/bulk_enroll
  def bulk_enroll
    active_students = Student.active
    enrolled_count = 0
    skipped_count = 0

    active_students.each do |student|
      student_season = @season.student_seasons.find_or_initialize_by(student: student)
      if student_season.new_record?
        student_season.save
        enrolled_count += 1
      else
        skipped_count += 1
      end
    end

    if enrolled_count > 0
      redirect_to admin_season_path(@season), notice: "Successfully enrolled #{enrolled_count} student(s). #{skipped_count} already enrolled."
    else
      redirect_to admin_season_path(@season), notice: "All active students are already enrolled in this season."
    end
  end

  private

  def set_season
    @season = Season.find(params[:id])
  end

  def season_params
    params.require(:season).permit(:name, :start_date, :end_date, :status)
  end
end
