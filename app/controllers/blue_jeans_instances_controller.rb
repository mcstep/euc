class BlueJeansInstancesController < CrudController
  def index
    super do
      @blue_jeans_instances = @blue_jeans_instances.where("client_id LIKE ?", "%#{params[:search]}%")
    end
  end
end
