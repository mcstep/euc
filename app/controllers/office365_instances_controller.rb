class Office365InstancesController < CrudController
  def index
    super do
      @office365_instances = @office365_instances.where("client_id LIKE ?", "%#{params[:search]}%")
    end
  end
end
