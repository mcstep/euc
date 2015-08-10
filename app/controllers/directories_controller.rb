class DirectoriesController < CrudController
  def index
    super do
      @directories = @directories.where("host LIKE ?", "%#{params[:search]}%")
    end
  end
end
