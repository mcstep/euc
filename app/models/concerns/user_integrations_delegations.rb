module UserIntegrationsDelegations
  extend ActiveSupport::Concern

  included do
    attr_accessor :integrations_disable_provisioning

    before_validation :ensure_profile
    before_validation :setup_integrations, on: :create
    after_save        :setup_authentication
  end

  def integrations_username
    @username.blank? ? email.try(:split, '@').try(:first) : @username
  end

  def integrations_username=(value)
    @username = value
  end

  def integrations_expiration_date
    @expiration_date || Date.today + 1.month
  end

  def integrations_expiration_date=(date)
    return if date.blank?
    date = date.to_date if date.respond_to?(:to_date)
    date = Date.parse(date) unless date.is_a?(Date)
    @expiration_date = date
  end

  def ensure_profile
    if profile.blank?
      if received_invitation.present?
        self.profile = received_invitation.from_user.profile
      elsif domain = Domain.where(name: email.split('@', 2).last).first
        self.profile = domain.profile
      end
    end
  end

  def setup_integrations
    if profile.present?
      effective_integrations = profile.profile_integrations.to_a
      effective_integrations = effective_integrations.select{|ei| ei.allow_sharing} if received_invitation.present?
      effective_integrations.map!(&:to_user_integration)

      effective_integrations.each do |ei|
        ei.user                      = self
        ei.directory_username        = integrations_username
        ei.directory_expiration_date = integrations_expiration_date
        ei.disable_provisioning      = integrations_disable_provisioning

        if original = user_integrations.select{|ui| ui.integration_id == ei.integration_id}.first
          ei.adapt(original)
        end
      end

      self.user_integrations = effective_integrations
    end
  end

  def setup_authentication
    if authentication_integration.blank? && user_integrations.any?
      self.authentication_integration = user_integrations.sort_by(&:authentication_priority).first
      save!
    end
  end
end