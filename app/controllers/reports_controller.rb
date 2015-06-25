class ReportsController < ApplicationController
  before_action :require_login

  def potential_seats
    unless current_user.admin?
        redirect_to dashboard_path, :alert => "Access denied."
    end
  end

private
    def require_login
      redirect_to log_in_path unless current_user
    end
end
