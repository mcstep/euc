class InvitationsController < ApplicationController
  def new
    authorize :invitation
  end

  def create
    authorize @invitation = Invitation.new(from_user: current_user)
    @invitation.assign_attributes(permitted_attributes(@invitation))

    if @invitation.save
      if UserPolicy.new(current_user).index?
        redirect_to users_path
      else
        redirect_to root_path, notice: I18n.t('flash.invitation_created')
      end
    else
      render action: 'new'
    end
  end
end
