class Api::V1::SupportRequestsController < Api::ApplicationController
  skip_after_action :verify_authorized

  def create
    support_request = SupportRequest.new
    support_request.assign_attributes(params[:support_request])
    support_request.from = current_user
    support_request.send!
    render nothing: true
  end
end
