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
#  blue_jeans_default_status   :integer
#  salesforce_default_status   :integer
#  box_default_status          :integer
#
# Indexes
#
#  index_profile_integrations_on_integration_id                 (integration_id)
#  index_profile_integrations_on_profile_id                     (profile_id)
#  index_profile_integrations_on_profile_id_and_integration_id  (profile_id,integration_id) UNIQUE
#

class ProfileIntegration < ActiveRecord::Base
  belongs_to :profile, -> { with_deleted }, inverse_of: :profile_integrations
  belongs_to :integration, -> { with_deleted }

  validates :profile,                   presence: true
  validates :integration,               presence: true
  validates :authentication_priority,   numericality: {allow_blank: true}

  Integration::SERVICES.each do |s|
    as_enum :"#{s}_default_status", {available: -3}, prefix: s
  end

  def to_user_integration(user_integration=nil)
    result = user_integration ? user_integration.dup : UserIntegration.new
    result.integration = integration

    Integration::SERVICES.each do |s|
      if !result.send("prohibit_#{s}") && self["#{s}_default_status"]
        result["#{s}_status"] = self["#{s}_default_status"]
      end
    end

    yield(result) if block_given?

    return result
  end
end
