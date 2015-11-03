class NominationSerializer < ActiveModel::Serializer
  attributes :company_name, :domain, :partner_type, :contact_name, :contact_email, :contact_phone,
    :profile_id, :approval
end