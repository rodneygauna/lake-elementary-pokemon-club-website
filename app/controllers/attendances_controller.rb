class AttendancesController < ApplicationController
  # Ensure only admins can access attendance functionality
  before_action :require_admin
  before_action :set_event, only: [ :toggle ]
  before_action :set_student, only: [ :toggle ]

  # POST /events/:event_id/attendances/toggle
  # Toggle attendance for a specific student at an event
  def toggle
    @attendance = Attendance.find_or_initialize_by(
      event: @event,
      student: @student
    )

    # Set the admin who is marking attendance
    @attendance.marked_by = current_user

    if @attendance.persisted?
      # If attendance record exists, toggle the presence
      @attendance.toggle_presence!
    else
      # If new record, mark as present (first time marking)
      @attendance.present = true
      @attendance.marked_at = Time.current
      @attendance.save!
    end

    respond_to do |format|
      format.json do
        render json: {
          success: true,
          present: @attendance.present,
          status: @attendance.status,
          marked_at: @attendance.marked_at&.strftime("%B %d, %Y at %I:%M %p"),
          marked_by: @attendance.marked_by_name
        }
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.json do
        render json: {
          success: false,
          error: e.record.errors.full_messages.join(", ")
        }, status: :unprocessable_entity
      end
    end
  end

  private

  def require_admin
    unless current_user&.admin?
      respond_to do |format|
        format.json { render json: { success: false, error: "Unauthorized" }, status: :unauthorized }
        format.html { redirect_to root_path, alert: "You must be an admin to access this feature." }
      end
    end
  end

  def set_event
    @event = Event.find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json: { success: false, error: "Event not found" }, status: :not_found }
    end
  end

  def set_student
    @student = Student.find(params[:student_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json: { success: false, error: "Student not found" }, status: :not_found }
    end
  end
end
