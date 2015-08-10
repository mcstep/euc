class ProfilesController < CrudController
  def index
    super do
      @profiles = @profiles.order(:name).page(params[:page])

      if params[:search].present?
        @profiles = @profiles.where("LOWER(name) LIKE LOWER(?)", "%#{params[:search]}%")
      end
    end
  end
end
