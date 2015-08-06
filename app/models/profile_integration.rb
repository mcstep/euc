# == Schema Information
#
# Table name: profile_integrations
#
#  id                          :integer          not null, primary key
#  profile_id                  :integer
#  integration_id              :integer
#  authentication_priority     :integer          default(100), not null
#  allow_sharing               :boolean          default(FALSE), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  office365_default_status    :integer
#  google_apps_default_status  :integer
#  airwatch_default_status     :integer
#  horizon_air_default_status  :integer
#  horizon_view_default_status :integer
#  horizon_rds_default_status  :integer
#
# Indexes
#
#  index_profile_integrations_on_integration_id                 (integration_id)
#  index_profile_integrations_on_profile_id                     (profile_id)
#  index_profile_integrations_on_profile_id_and_integration_id  (profile_id,integration_id) UNIQUE
#

class ProfileIntegration < ActiveRecord::Base
  belongs_to :profile
  belongs_to :integration

  validates :profile,     presence: true
  validates :integration, presence: true

  Integration::SERVICES.each do |s|
    as_enum :"#{s}_default_status", {available: -3}, prefix: s
  end

  def to_user_integration(user_integration=nil)
    result = UserIntegration.new(integration: integration)

    Integration::SERVICES.each do |s|
      result.send "#{s}_disabled=", user_integration.send("#{s}_disabled") if user_integration
      result["#{s}_status"] = self["#{s}_default_status"] if !result.send("#{s}_disabled") && self["#{s}_default_status"]
    end

    yield(result) if block_given?

    return result
  end
end
