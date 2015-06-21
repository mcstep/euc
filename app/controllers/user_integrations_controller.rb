class UserIntegrationsController < ApplicationController
  def prolong
    @user_integration = UserIntegration.find(params[:id])
    authorize @user_integration

    begin
      @user_integration.prolong!(current_user, params[:reason])
    rescue Exception => e
      redirect_back_or_default alert: I18n.t('flash.extension_error')
      return
    end

    redirect_back_or_default notice: I18n.t('flash.extended')
  end
end
