class ProfilePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :name, :home_template, :support_email, :group_name, :group_region, :supports_vidm,
      profile_integrations_attributes: [
        :id, :integration_id, :authentication_priority, :allow_sharing, :_destroy
      ]
    ]
  end

  def index?
    @user.root?
  end

  def create?
    @user.root?
  end
end