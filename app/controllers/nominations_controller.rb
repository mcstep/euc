class NominationsController < CrudController
  def index
    super do
      @nominations = @nominations.where("company_name ILIKE ?", "%#{params[:search]}%")
      @nominations = @nominations.order('id DESC')
    end
  end

  def create
    build_resource
    resource.assign_attributes(permitted_attributes(resource))
    resource.user = current_user
    authorize resource
    create!(notice: I18n.t('flash.nominated')){ root_path }
  end

  def decline
    @nomination = Nomination.find(params[:id])
    authorize @nomination
    @nomination.decline!

    redirect_to action: :index
  end

  def update
    resource
    resource.assign_attributes(permitted_attributes(resource))
    authorize resource

    if resource.save
      resource.approve!
      redirect_to action: :index
    else
      render action: :edit
    end
  end
end