class InvitationsController < ApplicationController
  def new
    authorize :invitation
  end

  def create
    authorize @invitation = Invitation.new(from_user: current_user)
    @invitation.assign_attributes(permitted_attributes(@invitation))

    if @invitation.save
      redirect_to users_path
    else
      render action: 'new'
    end
  end
end
