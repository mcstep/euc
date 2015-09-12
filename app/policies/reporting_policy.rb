class ReportingPolicy < ApplicationPolicy
  def users?
    @user.can_see_reports
  end

  def opportunities?
    @user.can_see_opportunities
  end
end