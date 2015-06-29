class RegistrationCodePolicy < ApplicationPolicy
  def permitted_attributes
    [:user_role, :user_validity, :valid_from, :valid_to, :total_registrations]
  end

  def index?
    @user.root?
  end

  def create?
    @user.root?
  end
end
