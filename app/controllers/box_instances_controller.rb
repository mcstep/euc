class BoxInstancesController < CrudController
  def index
    super do
      @box_instances = @box_instances.where("username LIKE ?", "%#{params[:search]}%")
    end
  end
end
