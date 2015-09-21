class InvitationUpdateCrmWorker
  include Sidekiq::Worker

  def perform(force: false)
    scope = if force
      Invitation.where.not(crm_id: nil)
    else
      changed  = []

      SalesforceInstance.joins(:company_resolving_opportunities).distinct.each do |si|
        changed += si.find_changed_opportunities
      end

      SalesforceInstance.joins(:company_resolving_dealregs).distinct.each do |si|
        changed += si.find_changed_dealregs
      end

      return if changed.blank?

      Invitation.joins(:to_user).where(users: {email: changed})
    end

    scope.where(crm_fetch_error: false).where("updated_at < ?", DateTime.now - 24.hours)
      .each(&:refresh_crm_data)
  end
end