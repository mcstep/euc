class CrudController < ApplicationController
  inherit_resources

  def index(&block)
    authorize resource_class
    index!(&block)
  end

  def new
    authorize build_resource
    new!
  end

  def edit
    authorize resource
    edit!
  end

  def create
    build_resource
    resource.assign_attributes(permitted_attributes(resource))
    authorize resource
    create!{ {action: :index} }
  end

  def update
    resource
    resource.assign_attributes(permitted_attributes(resource))
    authorize resource
    update!{ {action: :index} }
  end

  def destroy
    authorize resource
    destroy!
  end

protected

  # We are going to assign them manually
  # not using inherited_resources helper
  def permitted_params
    {}
  end
end