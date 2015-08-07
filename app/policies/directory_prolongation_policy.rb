class DirectoryProlongationPolicy < ApplicationPolicy
  def permitted_attributes
    attributes = [
      :reason, :user_integration_id
    ]
    attributes << :expiration_date_new if @user.root?
    attributes
  end

  def create?
    @user.root? || @record.user.invited_by.id == @user.id
  end
end
