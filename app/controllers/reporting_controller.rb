class ReportingController < ApplicationController
  def users
    authorize :reporting

    params[:companies] ||= []
    params[:regions]   ||= []

    if params[:start_date].present?
      @users = User.includes(sent_invitations: :to_user).where('created_at > ?', Date.parse(params[:start_date]))
      @invitations = Invitation.where('created_at > ?', Date.parse(params[:start_date]))

      if params[:end_date].present?
        @users = @users.where('created_at < ?', Date.parse(params[:end_date]))
        @invitations = @invitations.where('created_at < ?', Date.parse(params[:end_date]))
      end

      @users = @users.where(company_id: params[:companies]) if params[:companies].present?
      @users = @users.where(home_region: params[:regions]) if params[:regions].present?
    end

    @total = User.with_deleted
    @total = @total.where(company_id: params[:companies]) if params[:companies].present?
    @total = @total.where(home_region: params[:regions]) if params[:regions].present?

    @opportunity = Invitation.joins(:to_user).merge(@total).pluck(:potential_seats).compact.inject(:+)
  end

  def opportunities
    authorize :reporting

    @opportunities = Invitation.includes(:from_user).where.not(crm_id: nil).order(:id).page(params[:page]).per(10)
  end
end
