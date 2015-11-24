class UsersController < ApplicationController
  helper StatsHelper

  def index
    authorize :user
    @users = policy_scope(User).includes(:authentication_integration).page(params[:page])

    params[:order] ||= 'name'
    params[:desc]  = params[:desc].to_b
    params[:order] = 'name' unless User.respond_to?("order_by_#{params[:order]}")
    @users = @users.send("order_by_#{params[:order]}", params[:desc].to_b)

    if params[:search].present?
      @users = 
        if params[:search].match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
          @users.where('email LIKE ?', "%#{params[:search]}%")
        elsif params[:search].match(/\w+ \w+/i)
          f, l = params[:search].split(" ")
          @users.where('first_name LIKE ? AND last_name LIKE ?', "%#{f}%", "%#{l}%")
        else
          n = "%#{params[:search]}%"
          @users.distinct.joins(:user_integrations).where(
            'first_name LIKE ? OR last_name LIKE ? OR user_integrations.username LIKE ? OR email LIKE ?',
            n, n, n, n
          )
        end
    end
  end

  def show
    authorize @user = User.find(params[:id])
  end

  def edit
    authorize @user = User.find(params[:id])
    render layout: false
  end

  def update
    authorize @user = User.find(params[:id])

    @user.update_attributes(permitted_attributes(@user))
    redirect_to users_path, notice: I18n.t('flash.user_updated')
  end

  def recover
    authorize @user = User.find(params[:id])
    UserPasswordRecoverWorker.perform_async @user.id, @user.update_password
    redirect_to users_path, notice: I18n.t('flash.user_recovered')
  end

  def impersonate
    authorize @user = User.find(params[:id])

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

  def destroy
    authorize @user = User.find(params[:id])
    @user.destroy

    redirect_back_or_root
  end
end
