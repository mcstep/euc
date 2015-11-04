class ProfileIntegrationSerializer < ActiveModel::Serializer
  attributes :id, :authentication_priority, :allow_sharing, :office365_default_status, 
    :google_apps_default_status, :airwatch_default_status, :horizon_air_default_status,
    :horizon_view_default_statu, :horizon_rds_default_status, :blue_jeans_default_status,
    :salesforce_default_status, :box_default_status

  belongs_to :profile
  belongs_to :integration
end
