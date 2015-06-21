class InvitationsController < ApplicationController
  def new
    authorize :invitation
  end

  def create
    @invitation = Invitation.new(invitation_params.merge from_user: current_user)
    authorize @invitation

    if @invitation.save
      redirect_to users_path
    else
      render action: 'new'
    end
  end

  protected

  def invitation_params
    params.require(:invitation).permit(
      :potential_seats,
      to_user_attributes: [:first_name, :last_name, :email, :company_name, :job_title, :home_region, :role]
    )
  end
end
