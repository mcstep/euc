class DirectoryPolicy < ApplicationPolicy
  def permitted_attributes
    [ :display_name, :host, :port, :api_key, :stats_url ]
  end

  def index?
    @user.root? && @user.can_edit_services
  end

  def create?
    @user.root? && @user.can_edit_services
  end
end