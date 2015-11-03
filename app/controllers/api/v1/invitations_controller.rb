class Api::V1::InvitationsController < Api::ApplicationController
  def create
    authorize @invitation = Invitation.new(from_user: current_user)
    @invitation.assign_attributes(permitted_attributes @invitation)

    if @invitation.save
      render json: @invitation, include: ['to_user', 'to_user.profile', 'to_user.user_integrations', 'to_user.user_integrations.integartion']
    else
      render_errors(@invitation)
    end
  end
end
