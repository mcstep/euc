class SalesforceInstancesController < CrudController
  def index
    super do
      @salesforce_instances = @salesforce_instances.where("client_id LIKE ?", "%#{params[:search]}%")
    end
  end
end
