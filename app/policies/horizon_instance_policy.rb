class HorizonInstancePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :rds_group_name, :desktops_group_name, :view_group_name, :group_region,
      :api_key, :api_host, :api_port
    ]
  end

  def index?
    @user.root?
  end

  def create?
    @user.root?
  end
end