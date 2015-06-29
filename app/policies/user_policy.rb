class UserPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.root?
        scope.all
      else
        scope.joins(:received_invitation).where(invitations: {from_user_id: user.id})
      end
    end
  end

  def index?
    @user.root?
  end

  def update?
    @user.root?
  end

  def destroy?
    @user.root? || @record.invited_by.id == @user.id
  end

  def impersonate?
    @user.root?
  end

  def unimpersonate?
    true
  end

  # Global restrictions

  def system?
    @user.root?
  end

  def invites?
    InvitationPolicy.new(@user).create?
  end
end
