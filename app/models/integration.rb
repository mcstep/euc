# == Schema Information
#
# Table name: integrations
#
#  id                            :integer          not null, primary key
#  name                          :string
#  directory_id                  :integer
#  office365_instance_id         :integer
#  google_apps_instance_id       :integer
#  airwatch_instance_id          :integer
#  horizon_air_instance_id       :integer
#  horizon_workspace_instance_id :integer
#  horizon_view_instance_id      :integer
#  horizon_rds_instance_id       :integer
#  deleted_at                    :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_integrations_on_airwatch_instance_id           (airwatch_instance_id)
#  index_integrations_on_deleted_at                     (deleted_at)
#  index_integrations_on_directory_id                   (directory_id)
#  index_integrations_on_google_apps_instance_id        (google_apps_instance_id)
#  index_integrations_on_horizon_air_instance_id        (horizon_air_instance_id)
#  index_integrations_on_horizon_rds_instance_id        (horizon_rds_instance_id)
#  index_integrations_on_horizon_view_instance_id       (horizon_view_instance_id)
#  index_integrations_on_horizon_workspace_instance_id  (horizon_workspace_instance_id)
#  index_integrations_on_office365_instance_id          (office365_instance_id)
#

class Integration < ActiveRecord::Base
  acts_as_paranoid

  SERVICES = %w(
    horizon_air horizon_workspace horizon_rds horizon_view airwatch office365 google_apps
  )

  belongs_to :directory
  SERVICES.each{|s| belongs_to :"#{s}_instance"}

  validates :name, presence: true

  def domain
    google_apps_instance.domain
  end

  def enabled_services
    SERVICES.select{|k| self["#{k}_instance_id"]}
  end
end
