class Api::CrudController < Api::ApplicationController
  inherit_resources

  def index(&block)
    authorize resource_class
    render json: collection
  end

  def create
    build_resource
    resource.assign_attributes(permitted_attributes resource)
    authorize resource

    if resource.save
      render json: resource
    else
      render_errors(resource)
    end
  end

  def update
    resource
    resource.assign_attributes(permitted_attributes resource)
    authorize resource

    if resource.save
      render json: resource
    else
      render_errors(resource)
    end
  end

  def destroy
    authorize resource
    resource.destroy
    render nothing: true
  end

protected

  # We are going to assign them manually
  # not using inherited_resources helper
  def permitted_params
    {}
  end
end
