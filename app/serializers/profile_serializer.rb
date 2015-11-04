class ProfileSerializer < ActiveModel::Serializer
  attributes :id, :name, :home_template, :support_email, :group_name, :group_region, :supports_vidm,
    :implied_airwatch_eula, :requires_verification, :forced_user_validity

  has_many :profile_integrations
end
