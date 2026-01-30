class Admin::StudentSeasonsController < ApplicationController
  before_action :require_authentication
  before_action :require_admin_level
  before_action :set_student

  # POST /admin/students/:student_id/student_seasons
  def create
    @season = Season.find(params[:season_id])
    @student_season = @student.student_seasons.build(season: @season)

    if @student_season.save
      redirect_to student_path(@student), notice: "Student was successfully added to #{@season.name}."
    else
      redirect_to student_path(@student), alert: "Failed to add student to season: #{@student_season.errors.full_messages.join(', ')}"
    end
  end

  # DELETE /admin/students/:student_id/student_seasons/:id
  def destroy
    @student_season = @student.student_seasons.find(params[:id])
    season_name = @student_season.season.name
    season_id = @student_season.season_id
    @student_season.destroy!

    # Redirect back to the referring page (season or student profile)
    if request.referer&.include?("/admin/seasons/#{season_id}")
      redirect_to admin_season_path(season_id), notice: "Student was successfully removed from #{season_name}."
    else
      redirect_to student_path(@student), notice: "Student was successfully removed from #{season_name}."
    end
  end

  private

  def set_student
    @student = Student.find(params[:student_id])
  end
end
