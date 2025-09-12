class StudentsController < ApplicationController
  before_action :require_authentication, except: [ :index, :show ]
  before_action :set_student, only: %i[ show edit update destroy ]
  before_action :require_admin, only: [ :new, :create, :destroy ]
  before_action :require_admin_or_linked_parent, only: [ :edit, :update ]

  # GET /students or /students.json
  def index
    # Public can see limited info (initials + favorite pokemon)
    @students = Student.ordered
  end

  # GET /students/1 or /students/1.json
  def show
    # Public sees limited info, linked parents see full info
    @can_view_details = current_user&.admin? || (current_user && @student.users.include?(current_user))
    @linked_parents = @student.users if admin?
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def student_params
      params.expect(student: [ :first_name, :middle_name, :last_name, :suffix_name, :grade, :class_number, :teacher_name, :favorite_pokemon, :notes ])
    end

    # Ensure the current user is an admin or a parent linked to this student
    def require_admin_or_linked_parent
      unless current_user&.admin? || (current_user && @student.users.include?(current_user))
        redirect_to students_path, alert: "You do not have permission to view this student."
      end
    end

    # Ensure the current user is an admin
    def require_admin
      unless current_user&.admin?
        redirect_to students_path, alert: "You do not have permission to perform this action."
      end
    end
end
