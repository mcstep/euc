class DomainsController < CrudController
  def index
    super do
      @domains = @domains.where("LOWER(name) LIKE LOWER(?)", "%#{params[:search]}%") if params[:search].present?
    end
  end

  def toggle
    authorize resource
    resource.status = resource.active? ? 'inactive' : 'active'
    resource.save!
    redirect_to action: :index
  end
end
