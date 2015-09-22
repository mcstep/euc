class InvitationUpdateCrmWorker
  include Sidekiq::Worker

  def perform(force: false)
    scopes = []

    if force
      scopes << Invitation.where.not(crm_id: nil)
    else
      scopes << Invitation.where(
        crm_kind: CrmConfigurator.kinds[:salesforce_dealreg],
        crm_id:   SalesforceInstance.opportunity_sources.map(&:find_changed_dealregs).flatten
      )

      scopes << Invitation.where(
        crm_kind: CrmConfigurator.kinds[:salesforce_opportunity],
        crm_id:   SalesforceInstance.dealreg_sources.map(&:find_changed_opportunities).flatten
      )
    end

    scopes.each do |scope|
      scope.where(crm_fetch_error: false).each(&:refresh_crm_data)
    end
  end
end