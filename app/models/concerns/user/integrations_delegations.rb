module User::IntegrationsDelegations
  extend ActiveSupport::Concern

  included do
    after_create :setup_integrations!
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

  def setup_integrations!
    profile.profile_integrations.each do |pi|
      if invited_by.blank? || pi.allow_sharing
        UserIntegration.create!(
          user_id:                   id,
          integration_id:            pi.integration_id,
          directory_username:        integrations_username,
          directory_expiration_date: integrations_expiration_date,
          authentication_priority:   pi.authentication_priority
        )
      end
    end
  end
end