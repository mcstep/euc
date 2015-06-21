class RegistrationCodePolicy < ApplicationPolicy
  def index?
    @user.root?
  end

  def create?
    @user.root?
  end
end
