class BlueJeansInstanceSerializer < ActiveModel::Serializer
  attributes :id, :display_name, :group_name, :group_region, :grant_type, :client_id, :client_secret, :enterprise_id,
    :support_emails
end