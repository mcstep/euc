class DirectoryProlongationsController < ApplicationController
  def new
    @directory_prolongation = DirectoryProlongation.new(user_integration_id: params[:user_integration_id])
    authorize @directory_prolongation
  end

  def create
    @directory_prolongation = DirectoryProlongation.new(user_id: current_user.id)
    @directory_prolongation.assign_attributes(permitted_attributes @directory_prolongation)

    authorize @directory_prolongation
    
    if @directory_prolongation.save
      if UserPolicy.new(current_user).index?
        redirect_to users_path, notice: I18n.t('flash.extended')
      else
        redirect_to root_path, notice: I18n.t('flash.extended')
      end
    else
      render 'new'
    end
  end
end
