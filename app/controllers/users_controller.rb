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

  def update
    @user = User.find(params[:id])
    authorize @user

    @user.update_attributes(user_params)
    redirect_back_or_default users_path
  end

  def update_password
    @user = User.find(params[:id])
    authorize @user

    unless current_user.authenticate(params[:old_password])
      redirect_to root_path, alert: I18n.t('flash.invalid_current_password')
      return
    end

    if params[:password] != params[:password_confirmation]
      redirect_to root_path, alert: I18n.t('flash.invalid_confirmation')
      return
    end

    current_user.update_password(params[:password])
    redirect_to root_path, notice: I18n.t('flash.password_changed')
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
    params.require(:user).permit(:total_invitations, :avatar, :avatar_data_uri, :remove_avatar)
  end
end
