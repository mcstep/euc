class UsersController < ApplicationController
  def index
    authorize :user

    @users = policy_scope(User).order(:first_name).page(params[:page])

    if params[:search].present?
      @users = @users
      @users = 
        if params[:search].match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
          @users.where('email LIKE ?', "%#{params[:search]}%")
        elsif params[:search].match(/\w+ \w+/i)
          f, l = params[:search].split(" ")
          @users.where('first_name LIKE ? AND last_name LIKE ?', "%#{f}%", "%#{l}%")
        else
          n = "%#{params[:search]}%"
          @users.distinct.joins(:user_integrations).where(
            'first_name LIKE ? OR last_name LIKE ? OR user_integrations.directory_username LIKE ? OR email LIKE ?',
            n, n, n, n
          )
        end
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize @user

    render layout: false
  end

  def update
    @user = User.find(params[:id])
    authorize @user

    @user.update_attributes(user_params)
    redirect_to users_path, notice: I18n.t('flash.user_updated')
  end

  def impersonate
    @user = User.find(params[:id])
    authorize @user

    session[:impersonator_id] = current_user.id
    @current_user             = @user
    session[:user_id]         = @current_user.id

    redirect_to root_path
  end

  def unimpersonate
    authorize :user

    @current_user             = User.find session[:impersonator_id]
    session[:user_id]         = @current_user.id
    session[:impersonator_id] = nil

    redirect_to root_path
  end

protected

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :company_name, :job_title,
      :role, :home_region, :total_invitations,
      user_integrations_attributes: [:id, *Integration::SERVICES.map{|s| :"#{s}_disabled"}]
    )
  end
end
