class InvitationPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.root?
        scope.all
      else
        scope.where(from_user: user.id)
      end
    end
  end

  def permitted_attributes
    [
      :potential_seats, :crm_kind, :crm_id, to_user_attributes: UserPolicy.new(@user).permitted_attributes
    ]
  end

  def create?
    @user.root? || @user.admin?
  end

  def clean_opportunity?
    @user.root?
  end

  def refresh_opportunity?
    ReportingPolicy.new(user).opportunities?
  end
end
