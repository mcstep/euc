class Office365InstancePolicy < ApplicationPolicy
  def permitted_attributes
    [:group_name, :group_region, :client_id, :client_secret, :tenant_id, :resource_id]
  end

  def index?
    @user.root?
  end

  def create?
    @user.root?
  end
end