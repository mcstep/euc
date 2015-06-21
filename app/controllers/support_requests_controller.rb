class SupportRequestsController < ApplicationController
  skip_after_action :verify_authorized

  def create
    @support_request.assign_attributes(params[:support_request])
    @support_request.send!
    redirect_to root_path, notice: I18n.t('flash.support_request_sent')
  end
end
