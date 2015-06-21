class DomainsController < ApplicationController
  def index
    authorize :domain
    @domains = Domain.all
  end

  def destroy
    @domain = Domain.find(params[:id])
    authorize @domain
    @domain.destroy
    redirect_to domains_path
  end

  def toggle
    @domain = Domain.find_by_id(params[:id])
    authorize @domain
    @domain.status = @domain.active? ? 'inactive' : 'active'
    @domain.save!
    redirect_to domains_path
  end

  def create
    authorize :domain
    @domain = Domain.create(domain_params)
    redirect_to domains_path
  end
 
protected

  def domain_params
    params.require(:domain).permit(:name)
  end
end
