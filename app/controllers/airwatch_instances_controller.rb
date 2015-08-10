class AirwatchInstancesController < CrudController
  def index
    super do
      @airwatch_instances = @airwatch_instances.where("host LIKE ?", "%#{params[:search]}%")
    end
  end
end
