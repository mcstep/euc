class Api::V1::NominationsController < Api::ApplicationController
  def index
    authorize :nomination
    render json: Nomination.nominateds
  end

  def create
    authorize nomination = Nomination.new
    nomination.assign_attributes(permitted_attributes nomination)
    nomination.user = current_user

    if nomination.save
      render json: nomination
    else
      render_errors(nomination)
    end
  end

  def decline
    authorize nomination = Nomination.find(params[:id])
    nomination.decline!

    render nothing: true
  end

  def update
    authorize nomination = Nomination.find(params[:id])
    nomination.assign_attributes(permitted_attributes nomination)

    if nomination.save
      nomination.approve!
      render json: nomination
    else
      render_errors(nomination)
    end
  end
end
