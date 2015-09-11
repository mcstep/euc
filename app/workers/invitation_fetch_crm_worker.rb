class InvitationFetchCrmWorker
  include Sidekiq::Worker

  def perform(invitation_id)
    invitation = Invitation.find(invitation_id)
    instance   = invitation.from_user.company.crm_instance(invitation.crm_kind)

    return if instance.blank? || invitation.crm_kind.blank? || invitation.crm_id.blank?

    begin
      invitation.update_attributes(
        crm_fetch_error: false,
        crm_data: instance.fetch_crm_data(invitation.crm_kind, invitation.crm_id)
      )
    rescue Exception => e
      invitation.update_attributes(crm_fetch_error: true)
      raise e
    end
  end
end