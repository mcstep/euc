class Office365InstanceSerializer < ActiveModel::Serializer
  attributes :id, :display_name, :group_name, :group_region, :client_id, :client_secret, :tenant_id, :resource_id
end
