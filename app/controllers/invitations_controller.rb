class InvitationsController < ApplicationController
  def new
    authorize :invitation
    @invitation = Invitation.from(current_user)
  end

  def create
    @invitation = Invitation.new(invitation_params.merge from_user: current_user)
    authorize @invitation

    if @invitation.save
      redirect_to users_path
    else
      raise @invitation.errors.inspect
      render action: 'new'
    end
  end

  protected

  def invitation_params
    params.require(:invitation).permit(
      :potential_seats,
      to_user_attributes: [
        :first_name, :last_name, :email, :company_name, :job_title, :home_region, :role,
        user_integrations_attributes: [
          :integration_id, :authentication_priority, *Integration::SERVICES.map{|s| :"#{s}_disabled"}
        ]
      ]
    )
  end
end
