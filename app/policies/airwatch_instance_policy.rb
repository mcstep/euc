class AirwatchInstancePolicy < ApplicationPolicy
  def permitted_attributes
    [:display_name, :group_name, :group_region, :api_key, :host, :user, :password, :parent_group_id, :admin_roles_text]
  end

  def index?
    @user.root?
  end

  def create?
    @user.root?
  end
end