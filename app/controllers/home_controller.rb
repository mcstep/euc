class HomeController < ApplicationController
  before_action :require_login

  def index
    @invitation = Invitation.new
  end

  private
  def require_login
    redirect_to log_in_path unless current_user
  end
end
