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

  def refresh_opportunity
    authorize @invitation = Invitation.find(params[:id])
    @invitation.refresh_crm_data
    redirect_back_or_default invitations_path
  end

  def clean_opportunity
    authorize @invitation = Invitation.find(params[:id])
    @invitation.update_attributes(crm_id: nil, crm_kind: nil, crm_data: nil)
    redirect_back_or_default invitations_path
  end
end
