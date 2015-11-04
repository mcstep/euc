class SalesforceInstanceSerializer < ActiveModel::Serializer
  attributes :id, :display_name, :group_name, :group_region, :username, :password, :security_token,
    :client_id, :client_secret, :time_zone, :common_locale, :language_locale,
    :email_encoding, :profile_id, :host
end
