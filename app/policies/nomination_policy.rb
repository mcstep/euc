class NominationPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.root?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

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
    @user.profile.can_nominate || @user.root?
  end

  def update?
    @user.root?
  end

  def decline?
    index?
  end

  def decline_from_email?
    decline?
  end
end
