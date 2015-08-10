class IntegrationPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :name, :domain, :directory_id,
      :office365_instance_id, :google_apps_instance_id, :airwatch_instance_id,
      :horizon_air_instance_id, :horizon_view_instance_id, :horizon_rds_instance_id
    ]
  end

  def index?
    @user.root?
  end

  def create?
    @user.root?
  end
end