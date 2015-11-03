class UserIntegrationPolicy < ApplicationPolicy
  def toggle?
    @user.root? || @record.user_id == @user.id
  end
end