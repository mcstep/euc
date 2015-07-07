class DomainsController < ApplicationController
  def index
    authorize :domain
    @domains = Domain.all
  end

  def destroy
    authorize @domain = Domain.find(params[:id])
    @domain.destroy
    redirect_to domains_path
  end

  def toggle
    authorize @domain = Domain.find_by_id(params[:id])
    @domain.status = @domain.active? ? 'inactive' : 'active'
    @domain.save!
    redirect_to domains_path
  end

  def create
    authorize @domain = Domain.new
    @domain.assign_attributes(permitted_attributes(@domain))
    @domain.profile = Profile.where(name: 'Default').first
    @domain.save
    redirect_to domains_path
  end
end
