class DirectoryPolicy < ApplicationPolicy
  def permitted_attributes
    [ :host, :port, :api_key ]
  end

  def index?
    @user.root?
  end

  def create?
    @user.root?
  end
end