require "csv"

class Admin::ReportsController < ApplicationController
  before_action :require_authentication
  before_action :require_admin_level

  # GET /admin/reports
  def index
    # Display list of available reports
  end

  # GET /admin/reports/attendance
  # GET /admin/reports/attendance.csv
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

    respond_to do |format|
      format.html
      format.csv do
        csv_data = generate_attendance_csv
        filename = "attendance_report_#{params[:from_date]}_to_#{params[:to_date]}.csv"
        send_data csv_data, filename: filename, type: "text/csv", disposition: "attachment"
      end
    end
  rescue ArgumentError => e
    flash.now[:alert] = "Invalid date format. Please use valid dates."
    @events = []
  end

  private

  def generate_attendance_csv
    CSV.generate(headers: true) do |csv|
      csv << [ "Event Title", "Event Date", "Event Location", "Student First Name", "Student Last Name", "Student Grade" ]

      (@events || []).each do |event|
        event.attendances.present.includes(:student).order("students.last_name, students.first_name").each do |attendance|
          csv << [
            event.title,
            event.event_datetime_in_timezone,
            event.location,
            attendance.student.first_name,
            attendance.student.last_name,
            attendance.student.grade
          ]
        end
      end
    end
  end
end
