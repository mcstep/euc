# == Schema Information
#
# Table name: integrations
#
#  id                       :integer          not null, primary key
#  name                     :string
#  domain                   :string
#  directory_id             :integer
#  office365_instance_id    :integer
#  google_apps_instance_id  :integer
#  airwatch_instance_id     :integer
#  horizon_air_instance_id  :integer
#  horizon_view_instance_id :integer
#  horizon_rds_instance_id  :integer
#  deleted_at               :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  blue_jeans_instance_id   :integer
#  salesforce_instance_id   :integer
#
# Indexes
#
#  index_integrations_on_airwatch_instance_id      (airwatch_instance_id)
#  index_integrations_on_deleted_at                (deleted_at)
#  index_integrations_on_directory_id              (directory_id)
#  index_integrations_on_google_apps_instance_id   (google_apps_instance_id)
#  index_integrations_on_horizon_air_instance_id   (horizon_air_instance_id)
#  index_integrations_on_horizon_rds_instance_id   (horizon_rds_instance_id)
#  index_integrations_on_horizon_view_instance_id  (horizon_view_instance_id)
#  index_integrations_on_office365_instance_id     (office365_instance_id)
#

class Integration < ActiveRecord::Base
  acts_as_paranoid

  SERVICES = %w(
    horizon_view airwatch office365 google_apps blue_jeans salesforce
  )

  belongs_to :directory, -> { with_deleted }
  belongs_to :airwatch_instance, -> { with_deleted }
  belongs_to :office365_instance, -> { with_deleted }
  belongs_to :google_apps_instance, -> { with_deleted }
  belongs_to :horizon_air_instance, -> { with_deleted }
  belongs_to :blue_jeans_instance, -> { with_deleted }
  belongs_to :salesforce_instance, -> { with_deleted }
  belongs_to :horizon_rds_instance, -> { with_deleted }, class_name: 'HorizonInstance'
  belongs_to :horizon_view_instance, -> { with_deleted }, class_name: 'HorizonInstance'

  validates :name, presence: true, uniqueness: { scope: :deleted_at }
  validates :domain, hostname: true

  def enabled_services
    SERVICES.select{|k| self["#{k}_instance_id"] || send(:"#{k}_instance")}
  end

  def disabled_services
    SERVICES - enabled_services
  end
end
