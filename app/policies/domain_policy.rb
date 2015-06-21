class DomainPolicy < ApplicationPolicy
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