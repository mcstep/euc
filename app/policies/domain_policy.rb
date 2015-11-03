class DomainPolicy < ApplicationPolicy
  def permitted_attributes
    [:name, :profile_id, :user_role, :total_invitations, :user_validity]
  end

  def index?
    @user.root?
  end

  def create?
    @user.root?
  end

  def toggle?
    @user.root?
  end
end