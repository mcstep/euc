module CrmConfigurator extend ActiveSupport::Concern
  included do
    as_enum :crm_kind, CrmConfigurator.kinds

    after_commit(on: :update) do
      CrmConfigurator.kinds.each do |kind_key, kind_value|
        if previous_changes.key?("#{kind_key}_instance_id") && self["#{kind_key}_instance_id"].present?
          sent_invitations.where(crm_kind: kind_value).each(&:refresh_crm_data)
        end
      end
    end

    belongs_to :salesforce_opportunity_instance, class_name: 'SalesforceInstance'
    belongs_to :salesforce_dealreg_instance, class_name: 'SalesforceInstance'
  end

  def crm_instance(crm_kind)
    return nil if crm_kind.blank?
    self.send(:"#{crm_kind}_instance")
  end

  def self.kinds
    {salesforce_dealreg: 0, salesforce_opportunity: 1}
  end
end