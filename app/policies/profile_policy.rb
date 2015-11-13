class ProfilePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :name, :home_template, :support_email, :group_name, :group_region, :supports_vidm, :implied_airwatch_eula,
      :requires_verification, :forced_user_validity, :can_nominate,
      profile_integrations_attributes: [
        :id, :integration_id, :authentication_priority, :allow_sharing, :_destroy
      ]
    ]
  end

  def index?
    @user.root? && @user.can_edit_services
  end

  def create?
    @user.root? && @user.can_edit_services
  end
end