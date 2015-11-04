class UserIntegrationSerializer < ActiveModel::Serializer
  attributes :id, :username, :directory_expiration_date, :directory_status, :horizon_air_status,
    :horizon_rds_status, :horizon_view_status, :airwatch_status, :office365_status, :google_apps_status,
    :blue_jeans_status, :salesforce_status, :box_status, :prohibited_services,
    :integration_id, :integration_name

  belongs_to :integration
end
