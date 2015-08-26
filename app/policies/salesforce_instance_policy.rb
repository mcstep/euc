class SalesforceInstancePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :display_name, :group_name, :group_region, :username, :password, :security_token,
      :client_id, :client_secret, :time_zone, :common_locale, :language_locale,
      :email_encoding, :profile_id
    ]
  end

  def index?
    @user.root? && @user.can_edit_services
  end

  def create?
    @user.root? && @user.can_edit_services
  end
end