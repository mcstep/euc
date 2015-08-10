class GoogleAppsInstancePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :group_name, :group_region, :key_file, :key_base64, :key_password,
      :initial_password, :service_account, :act_on_behalf
    ]
  end

  def index?
    @user.root?
  end

  def create?
    @user.root?
  end
end