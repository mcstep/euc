class InvitationSerializer < ActiveModel::Serializer
  attributes :id, :sent_at, :crm_kind, :crm_id, :sent_at

  belongs_to :to_user
end
