class UserIntegrationsController < ApplicationController
  skip_after_action :verify_authorized

  def toggle
    user_integration = current_user.user_integrations.find(params[:id])
    state_machine    = user_integration[params[:service]]

    if state_machine.trigger?(:toggle)
      state_machine.toggle
      user_integration.save!

      if state_machine.disabled?
        redirect_to services_current_user_path, notice: I18n.t('flash.service_disabled', service: params[:service].camelize)
      else
        redirect_to services_current_user_path, notice: I18n.t('flash.service_enabled', service: params[:service].camelize)
      end
    else
      redirect_to services_current_user_path, error: I18n.t('flash.service_not_toggled')
    end
  end
end
