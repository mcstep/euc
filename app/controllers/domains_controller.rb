class DomainsController < ApplicationController
  def index
    @domains = Domain.all
  end

  def destroy
    @domain = Domain.find_by_id(params[:id])
    @domain.destroy
    respond_to do |format|
      format.html { redirect_to domains_path }
      format.json { head :no_content }
    end
  end

  def toggle
    @domain = Domain.find_by_id(params[:id])
    if @domain.status == 'active'
       @domain.status = 'inactive'
    else
       @domain.status = 'active'
    end
    @domain.save
    respond_to do |format|
      format.html { redirect_to domains_path }
      format.json { head :no_content }
    end
  end

  def create
    puts params
    @domain = Domain.new(domain_params)
    @domain.status = 'active'
    @domain.save
    respond_to do |format|
      format.html { redirect_to domains_path }
      format.json { head :no_content }
    end
  end
 
  private

  def domain_params
    params.require(:domain).permit(:name)
  end
end
