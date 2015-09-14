class InvitationUpdateCrmWorker
  include Sidekiq::Worker

  def perform
    Invitation.where.not(crm_id: nil)
      .where(crm_fetch_error: false)
      .where("updated_at < ?", DateTime.now - 24.hours)
      .each(&:refresh_crm_data)
  end
end