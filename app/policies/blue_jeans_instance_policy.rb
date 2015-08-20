class BlueJeansInstancePolicy < ApplicationPolicy
  def permitted_attributes
    [:display_name, :group_name, :group_region, :grant_type, :client_id, :client_secret, :enterprise_id]
  end

  def index?
    @user.root?
  end

  def create?
    @user.root?
  end
end