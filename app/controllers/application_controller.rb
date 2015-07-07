class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  helper_method :current_user
  before_action :require_login
  before_action :setup_global_forms, if: :current_user
  after_action  :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def user_not_authorized
    flash[:alert] = I18n.t 'flash.access_denied'
    redirect_to(request.referrer || root_path)
  end

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
      @current_user ||= User.find(cookies[:user_id]) if cookies[:user_id] && Rails.env.test?
    rescue ActiveRecord::RecordNotFound 
      session[:user_id] = session[:impersonator_id] = nil
    end
  end

  def require_login
    redirect_to new_session_path unless current_user
  end

  def setup_global_forms
    @invitation = Invitation.from(current_user)
    @support_request = SupportRequest.new(from: current_user)
  end

  def redirect_back_or_root(*params)
    redirect_back_or_default root_path, *params
  end

  def redirect_back_or_default(path, *params)
    redirect_to :back, *params
  rescue ActionController::RedirectBackError
    redirect_to path, *params
  end
end
