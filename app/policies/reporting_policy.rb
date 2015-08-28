class ReportingPolicy < ApplicationPolicy
  def users?
    @user.can_see_reports
  end
end