class AirwatchInstancePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :display_name, :group_name, :group_region, :api_key, :host, :user, :password,
      :parent_group_id, :admin_roles_text, :use_groups, :use_admin, :use_templates,
      :templates_api_url, :templates_token
    ]
  end

  def index?
    @user.root? && @user.can_edit_services
  end

  def create?
    @user.root? && @user.can_edit_services
  end
end