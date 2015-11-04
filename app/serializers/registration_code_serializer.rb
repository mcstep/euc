class RegistrationCodeSerializer < ActiveModel::Serializer
  attributes :id, :profile_id, :code, :user_role, :user_validity, :valid_from, :valid_to, :total_registrations
end
