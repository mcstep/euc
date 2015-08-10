class RegistrationCodePolicy < ApplicationPolicy
  def permitted_attributes
    [:profile_id, :code, :user_role, :user_validity, :valid_from, :valid_to, :total_registrations]
  end

  def index?
    @user.root?
  end

  def create?
    @user.root?
  end
end
