class BoxInstancePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :display_name, :group_name, :group_region, :token_retriever_url, :username, :password,
      :client_id, :client_secret
    ]
  end

  def index?
    @user.root? && @user.can_edit_services
  end

  def create?
    @user.root? && @user.can_edit_services
  end
end