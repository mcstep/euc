class DeliveryPolicy < ApplicationPolicy
  def permitted_attributes
    [ :profile_id, :body, :send_at, :from_email, :subject ]
  end

  def create?
    @user.root?
  end
end