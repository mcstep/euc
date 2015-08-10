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
    authorize build_resource
    resource.assign_attributes(permitted_attributes(resource))
    create!{ {action: :index} }
  end

  def update
    authorize resource
    resource.assign_attributes(permitted_attributes(resource))
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