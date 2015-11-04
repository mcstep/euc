class GoogleAppsInstanceSerializer < ActiveModel::Serializer
  attributes :id, :display_name, :group_name, :group_region, :key_file, :key_base64, :key_password,
    :initial_password, :service_account, :act_on_behalf
end
