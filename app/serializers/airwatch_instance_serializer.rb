class AirwatchInstanceSerializer < ActiveModel::Serializer
  attributes :display_name, :group_name, :group_region, :api_key, :host, :user, :password,
    :security_pin, :parent_group_id, :admin_roles_text, :use_groups, :use_admin,
    :use_templates, :templates_api_url, :templates_token
end