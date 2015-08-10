class HorizonInstancesController < CrudController
  def index
    super do
      @horizon_instances = @horizon_instances.where("api_host LIKE ?", "%#{params[:search]}%")
    end
  end
end
