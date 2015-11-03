class Api::V1::UsersController < Api::ApplicationController
  def index
    authorize :user
    render json: policy_scope(User), include: ['profile', 'user_integrations', 'user_integrations.integartion']
  end

  def update
    authorize @user = User.find(params[:id])
    @user.assign_attributes(permitted_attributes @user)

    if @user.save
      render json: @user
    else
      render_errors(@user)
    end
  end

  def recover
    authorize @user = User.find(params[:id])
    UserPasswordRecoverWorker.perform_async @user.id
    render nothing: true
  end

  def destroy
    authorize @user = User.find(params[:id])
    @user.destroy
    render nothing: true
  end
end
