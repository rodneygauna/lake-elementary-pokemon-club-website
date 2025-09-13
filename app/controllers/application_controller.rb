class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def require_admin
    unless current_user&.admin?
      respond_to do |format|
        format.json do
          render json: { success: false, error: "Unauthorized" }, status: :unauthorized
        end
        format.html do
          redirect_to root_path, alert: "Access denied. Admin privileges required."
        end
      end
    end
  end
end
