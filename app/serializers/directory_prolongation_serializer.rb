class DirectoryProlongationSerializer < ActiveModel::Serializer
  attributes :id, :reason, :expiration_date_old, :expiration_date_new

  belongs_to :user_integration
end
