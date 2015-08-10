class IntegrationsController < CrudController
  def index
    super do
      @integrations = @integrations.order(:name).page(params[:page])

      if params[:search].present?
        @integrations = @integrations.where("LOWER(name) LIKE LOWER(?)", "%#{params[:search]}%")
      end
    end
  end
end
