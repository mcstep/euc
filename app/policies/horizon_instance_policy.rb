class HorizonInstancePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :display_name, :rds_group_name, :desktops_group_name, :view_group_name, :group_region,
      :api_key, :api_host, :api_port
    ]
  end

  def index?
    @user.root? && @user.can_edit_services
  end

  def create?
    @user.root? && @user.can_edit_services
  end
end