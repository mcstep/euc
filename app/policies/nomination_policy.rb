class NominationPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :company_name, :domain, :partner_type, :contact_name, :contact_email, :contact_phone,
      :profile_id, :approval, :partner_id
    ]
  end

  def create?
    @user.profile.can_nominate || @user.root?
  end

  def index?
    @user.root?
  end

  def update?
    index?
  end

  def decline?
    index?
  end
end