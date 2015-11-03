class Api::ApplicationController  < ActionController::Base
  include Pundit

  before_action :doorkeeper_authorize!
  after_action  :verify_authorized

  def current_user
    @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def render_errors(model=resource)
    render json: { errors: model.errors.full_messages }, status: :bad_request
  end
end
