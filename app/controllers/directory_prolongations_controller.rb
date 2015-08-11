class DirectoryProlongationsController < ApplicationController
  def create
    @directory_prolongation = DirectoryProlongation.new(user_id: current_user.id)
    @directory_prolongation.assign_attributes(permitted_attributes @directory_prolongation)

    authorize @directory_prolongation
    @directory_prolongation.save!

    redirect_back_or_root notice: I18n.t('flash.extended')
  end
end
