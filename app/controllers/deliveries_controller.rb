class DeliveriesController < ApplicationController
  inherit_resources

  def new
    authorize build_resource
    new!
  end

  def create
    build_resource
    resource.assign_attributes(permitted_attributes(resource))
    authorize resource
    create! do |success, failure|
      success.html{ render 'create' }
      failure.html{ render 'new' }
    end
  end

protected

  # We are going to assign them manually
  # not using inherited_resources helper
  def permitted_params
    {}
  end
end
