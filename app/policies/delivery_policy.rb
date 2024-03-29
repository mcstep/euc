class DeliveryPolicy < ApplicationPolicy
  def permitted_attributes
    [ :profile_id, :body, :global, :send_at, :from_email, :subject, :adhoc_emails ]
  end

  def create?
    @user.root?
  end
end