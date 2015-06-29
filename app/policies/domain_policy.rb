class DomainPolicy < ApplicationPolicy
  def permitted_attributes
    [:name]
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