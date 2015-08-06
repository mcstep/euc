class DirectoryProlongationPolicy < ApplicationPolicy
  def permitted_attributes
    attributes = [
      :user_id, :user_integration_id, :reason
    ]
    attributes << :expiration_date_new if @user.root?
    attributes
  end
end
