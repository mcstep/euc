class UserIntegrationsController < ApplicationController
  def prolong
    authorize @user_integration = UserIntegration.find(params[:id])

    data = params.require(:directory_prolongation).permit(
      DirectoryProlongationPolicy.new(current_user, @user_integration).permitted_attributes
    )

    DirectoryProlongation.create!(
      user_id:             current_user.id,
      user_integration_id: @user_integration.id,
      expiration_date_new: data[:expiration_date_new],
      reason:              params[:reason]
    )

    redirect_back_or_root notice: I18n.t('flash.extended')
  end
end
