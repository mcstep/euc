class DomainSerializer < ActiveModel::Serializer
  attributes :id, :name, :profile_id, :user_role, :total_invitations, :user_validity
end
