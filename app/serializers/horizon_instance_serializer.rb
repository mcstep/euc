class HorizonInstanceSerializer < ActiveModel::Serializer
  attributes :id, :display_name, :rds_group_name, :desktops_group_name, :view_group_name, :group_region,
    :api_key, :api_host, :api_port
end
