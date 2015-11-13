class ReportingController < ApplicationController
  def users
    authorize :reporting

    params[:companies] ||= []
    params[:regions]   ||= []

    exclusion = '%vmware%'

    if params[:start_date].present?
      @users = User.includes(sent_invitations: :to_user).where('users.created_at > ?', Date.parse(params[:start_date]))
      @invitations = Invitation.where('invitations.created_at > ?', Date.parse(params[:start_date]))

      if params[:end_date].present?
        @users = @users.where('users.created_at < ?', Date.parse(params[:end_date]))
        @invitations = @invitations.where('invitations.created_at < ?', Date.parse(params[:end_date]))
      end

      if params[:regions].present?
        @users = @users.where(home_region: params[:regions])
        @invitations = @invitations.includes(:to_user).where(users: {home_region: params[:regions]})
      end

      @users = @users.where(company_id: params[:companies]) if params[:companies].present?

      unless current_user.root?
        @users = @users.joins(:company).where("companies.name NOT ILIKE ?", exclusion)
        @invitations = @invitations.joins(to_user: :company).where("companies.name NOT ILIKE ?", exclusion)
      end
    end

    @total = User.with_deleted
    @total = @total.where(company_id: params[:companies]) if params[:companies].present?
    @total = @total.where(home_region: params[:regions]) if params[:regions].present?

    @opportunity = Invitation.joins(:to_user).merge(@total)
    @opportunity = @opportunity.joins(to_user: :company).where("companies.name NOT ILIKE ?", exclusion) unless current_user.root?
    @opportunity = @opportunity.pluck(:potential_seats).compact.inject(:+) || 0

    @total = @total.joins(:company).where("companies.name NOT ILIKE ?", exclusion) unless current_user.root?
  end

  def opportunities
    authorize :reporting

    @opportunities = Invitation.includes(:from_user).where.not(crm_id: '').order(:id).page(params[:page]).per(10)
  end
end
