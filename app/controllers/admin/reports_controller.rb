class Admin::ReportsController < ApplicationController
  before_action :require_authentication
  before_action :require_admin_level

  # GET /admin/reports
  def index
    # Display list of available reports
  end

  # GET /admin/reports/attendance
  def attendance_report
    if params[:from_date].present? && params[:to_date].present?
      # Parse dates and set timezone
      tz = "America/Los_Angeles" # Default timezone for the app
      zone = ActiveSupport::TimeZone[tz] || Time.zone

      # Parse the dates in the timezone
      @from_date = Date.parse(params[:from_date])
      @to_date = Date.parse(params[:to_date])

      # Convert to UTC for database query
      from_datetime = zone.parse(@from_date.to_s).beginning_of_day.utc
      to_datetime = zone.parse(@to_date.to_s).end_of_day.utc

      # Query events within the date range
      @events = Event.where("starts_at >= ? AND starts_at <= ?", from_datetime, to_datetime)
                    .published
                    .ordered
                    .includes(attendances: :student)

      # Calculate totals
      @total_events = @events.count
      @total_attendances = @events.sum { |event| event.attendances.present.count }
    end
  rescue ArgumentError => e
    flash.now[:alert] = "Invalid date format. Please use valid dates."
    @events = []
  end
end
