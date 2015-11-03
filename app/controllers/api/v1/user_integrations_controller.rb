class Api::V1::UserIntegrationsController < Api::ApplicationController
  def toggle
    authorize user_integration = UserIntegration.find(params[:id])
    state_machine = user_integration[params[:service]]

    if state_machine.try(:trigger?, :toggle)
      state_machine.toggle
      user_integration.save!
      render nothing: true
    else
      render nothing: true, status: :bad_request
    end
  end
end
