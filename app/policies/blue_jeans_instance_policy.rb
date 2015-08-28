class BlueJeansInstancePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :display_name, :group_name, :group_region, :grant_type, :client_id, :client_secret, :enterprise_id,
      :support_emails
    ]
  end

  def index?
    @user.root? && @user.can_edit_services
  end

  def create?
    @user.root? && @user.can_edit_services
  end
end