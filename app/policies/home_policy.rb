class HomePolicy < ApplicationPolicy
  def index?
    true
  end

  def root?
    @user.root?
  end
end