class IntegrationSerializer < ActiveModel::Serializer
  attributes :id, :name, :domain, :directory_id,
    :office365_instance_id, :google_apps_instance_id, :airwatch_instance_id,
    :horizon_air_instance_id, :horizon_view_instance_id, :horizon_rds_instance_id,
    :blue_jeans_instance_id, :salesforce_instance_id
end
