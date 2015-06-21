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

  belongs_to :directory
  belongs_to :office365_instance
  belongs_to :google_apps_instance
  belongs_to :airwatch_instance
  belongs_to :horizon_air_instance
  belongs_to :horizon_view_instance
  belongs_to :horizon_rds_instance

  validates :name, presence: true

  def enabled_services
    attributes.select{|k,v| k.ends_with?('instance_id') && v}.keys.map{|k| k[0..-13]}
  end
end
