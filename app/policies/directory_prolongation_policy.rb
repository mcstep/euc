class DirectoryProlongationPolicy < ApplicationPolicy
  def permitted_attributes
    attributes = [
      :reason, :user_integration_id
    ]
    attributes << :expiration_date_new if @user.root?
    attributes
  end

  def create?
    @user.root? || (@record && @record.user_integration.user.invited_by.try(:id) == @user.id)
  end
end
