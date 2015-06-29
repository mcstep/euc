module User::IntegrationsDelegations
  extend ActiveSupport::Concern

  included do
    before_validation :setup_integrations
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
    date = Date.parse(date) unless date.is_a?(Date)
    @expiration_date = date
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

        if original = user_integrations.select{|ui| ui.integration_id == ei.integration_id}.first
          ei.adapt(original)
        end
      end

      self.user_integrations = effective_integrations
    end
  end
end