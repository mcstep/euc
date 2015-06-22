class SessionsController < ApplicationController
  skip_before_action :require_login
  skip_after_action :verify_authorized

  def new; end

  def create
    user = User.where(email: params[:email]).first

    if user && user.authenticate(params[:password])
      @current_user = user
      session[:user_id] = user.id
      redirect_to root_path, notice: I18n.t('flash.logged_in')
    else
      flash.now.alert = I18n.t('flash.bad_authentication')
      render 'new'
    end
  end

  def destroy
    session[:user_id] = session[:impersonator_id] = nil
    redirect_to root_path, notice: I18n.t('flash.logged_out')
  end

  def recover
    @user = User.where(email: params[:email]).first

    if @user.blank?
      redirect_to new_session_path, alert: I18n.t('flash.recover_error')
      return
    end

    begin
      PasswordResetWorker.perform_async @user.id, @user.update_password
    rescue Exception => e
      redirect_to new_session_path, alert: I18n.t('flash.recover_error')
      return
    end

    redirect_to new_session_path, notice: I18n.t('flash.recovered')
  end
end
