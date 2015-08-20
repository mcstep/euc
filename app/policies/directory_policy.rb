class DirectoryPolicy < ApplicationPolicy
  def permitted_attributes
    [ :display_name, :host, :port, :api_key, :stats_url ]
  end

  def index?
    @user.root?
  end

  def create?
    @user.root?
  end
end