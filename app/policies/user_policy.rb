class UserPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      result = if user.root?
        scope.all
      else
        scope.joins(:received_invitation).where(invitations: {from_user_id: user.id})
      end

      result.where.not(id: user.id)
    end
  end

  def permitted_attributes
    attributes = [
      :first_name, :last_name, :email, :company_name, :job_title, :home_region, :total_invitations,
      :integrations_username,
      user_integrations_attributes: [
        :id, :integration_id, *Integration::SERVICES.map{|s| :"#{s}_disabled"}
      ]
    ]

    attributes += [:role, :integrations_expiration_date, :profile_id] if @user.root?

    attributes
  end

  def index?
    @user.root?
  end

  def update?
    @user.root? && @user.id != @record.id
  end

  def destroy?
    (@user.root? || @record.invited_by.id == @user.id) && @user.id != @record.id
  end

  def impersonate?
    @user.root?
  end

  def unimpersonate?
    true
  end

  def sidekiq?
    @user.root?
  end
end
