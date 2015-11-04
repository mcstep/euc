class BoxInstanceSerializer < ActiveModel::Serializer
  attributes :id, :display_name, :group_name, :group_region, :token_retriever_url, :username, :password,
    :client_id, :client_secret
end
