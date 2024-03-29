class GoogleAppsInstancePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :display_name, :group_name, :group_region, :key_file, :key_base64, :key_password,
      :initial_password, :service_account, :act_on_behalf
    ]
  end

  def index?
    @user.root? && @user.can_edit_services
  end

  def create?
    @user.root? && @user.can_edit_services
  end
end