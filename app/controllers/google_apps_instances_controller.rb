class GoogleAppsInstancesController < CrudController
  def index
    super do
      @google_apps_instances = @google_apps_instances.where("act_on_behalf LIKE ?", "%#{params[:search]}%")
    end
  end
end
