class UserStudentsController < ApplicationController
  before_action :require_authentication
  before_action :require_admin

  def create
    @user_student = UserStudent.new(user_student_params)
    @student = Student.find(params[:student_id])

    if @user_student.save
      redirect_to @student, notice: "Parent was successfully linked to student."
    else
      redirect_to @student, alert: "Failed to link parent to student: #{@user_student.errors.full_messages.to_sentence}"
    end
  end

  def destroy
    @user_student = UserStudent.find(params[:id])
    @student = @user_student.student
    @user_student.destroy!

    redirect_to @student, notice: "Parent was successfully unlinked from student."
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
