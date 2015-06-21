class UserIntegrationPolicy < ApplicationPolicy
  def prolong?
    @user.root? || @record.user.invited_by.id == @user.id
  end
end