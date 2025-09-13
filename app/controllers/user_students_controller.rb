class UserStudentsController < ApplicationController
  before_action :require_authentication
  before_action :require_admin

  def create
    @student = Student.find(params[:student_id])
    @user_student = UserStudent.new(user_student_params.merge(student_id: @student.id))

    if @user_student.save
      if params[:redirect_to].present?
        redirect_to params[:redirect_to], notice: "Student was successfully linked to parent."
      else
        redirect_to @student, notice: "Parent was successfully linked to student."
      end
    else
      if params[:redirect_to].present?
        redirect_to params[:redirect_to], alert: "Failed to link student to parent: #{@user_student.errors.full_messages.to_sentence}"
      else
        redirect_to @student, alert: "Failed to link parent to student: #{@user_student.errors.full_messages.to_sentence}"
      end
    end
  end

  def destroy
    @user_student = UserStudent.find(params[:id])
    @student = @user_student.student
    @user_student.destroy!

    if params[:redirect_to].present?
      redirect_to params[:redirect_to], notice: "Student was successfully unlinked from parent."
    else
      redirect_to @student, notice: "Parent was successfully unlinked from student."
    end
  end

  private

  def user_student_params
    params.expect(user_student: [ :user_id, :student_id ])
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "You do not have permission to perform this action."
    end
  end
end
