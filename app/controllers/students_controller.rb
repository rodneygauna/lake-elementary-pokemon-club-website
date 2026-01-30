class StudentsController < ApplicationController
  before_action :require_authentication, except: [ :index, :show ]
  before_action :set_student, only: %i[ show edit update destroy ]
  before_action :require_admin_level, only: [ :new, :create, :bulk_deactivate ]
  before_action :require_admin, only: [ :destroy ]
  before_action :require_admin_or_linked_parent, only: [ :edit, :update ]

  # GET /students or /students.json
  def index
    # Public can see limited info (initials + favorite pokemon)
    # By default, show only active students unless explicitly requested to show all
    if params[:show_inactive] == "true"
      @students = Student.by_last_name
      @show_inactive = true
    else
      @students = Student.active.by_last_name
      @show_inactive = false
    end
  end

  # GET /students/1 or /students/1.json
  def show
    # Public sees limited info, linked parents see full info
    @can_view_details = current_user&.admin_level? || (current_user && @student.users.include?(current_user))
    @linked_parents = @student.users if admin_level?

    # Load attendance history for authorized users (following same privacy rules)
    if @can_view_details
      @attended_events = @student.attendances
                                 .present
                                 .includes(event: [])
                                 .joins(:event)
                                 .order("events.starts_at DESC")
    end
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # GET /students/1/edit
  def edit
  end

  # POST /students or /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.save
        format.html { redirect_to @student, notice: "Student was successfully created." }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1 or /students/1.json
  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to @student, notice: "Student was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1 or /students/1.json
  def destroy
    @student.destroy!

    respond_to do |format|
      format.html { redirect_to students_path, notice: "Student was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # POST /students/bulk_deactivate
  def bulk_deactivate
    active_students = Student.active
    deactivated_count = 0

    active_students.each do |student|
      if student.update(status: :inactive)
        deactivated_count += 1
      end
    end

    if deactivated_count > 0
      redirect_to students_path(show_inactive: true), notice: "Successfully deactivated #{deactivated_count} student(s)."
    else
      redirect_to students_path, notice: "No active students to deactivate."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def student_params
      params.expect(student: [ :first_name, :middle_name, :last_name, :suffix_name, :grade, :class_number, :teacher_name, :favorite_pokemon, :notes, :status ])
    end

    # Ensure the current user is an admin or a parent linked to this student
    def require_admin_or_linked_parent
      unless current_user&.admin_level? || (current_user && @student.users.include?(current_user))
        redirect_to students_path, alert: "You do not have permission to view this student."
      end
    end
end
