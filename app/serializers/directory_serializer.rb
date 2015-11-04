class DirectorySerializer < ActiveModel::Serializer
  attributes :id, :display_name, :host, :port, :api_key, :stats_url
end
