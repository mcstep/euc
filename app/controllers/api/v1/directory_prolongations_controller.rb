class Api::V1::DirectoryProlongationsController < Api::ApplicationController
  def create
    authorize directory_prolongation = DirectoryProlongation.new(user_id: current_user.id)
    directory_prolongation.assign_attributes(permitted_attributes directory_prolongation)

    if directory_prolongation.save
      render json: directory_prolongation, include: ['user_integration', 'user_integration.integration']
    else
      render_errors(directory_prolongation)
    end
  end
end
