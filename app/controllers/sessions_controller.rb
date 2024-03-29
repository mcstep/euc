class SessionsController < ApplicationController
  layout false
  
  skip_before_action :require_login
  skip_after_action :verify_authorized

  def new
    @small_footer = true
    redirect_to root_path if current_user
  end

  def create
    user = User.identified_by(params[:email])

    if user && user.verification_required?
      redirect_to new_user_verification_path(user)
      return
    elsif user && user.authenticate(params[:password])
      UserAuthentication.create!(ip: request.remote_ip, successful: true, user_id: user.id)
      user.update_attributes(last_authorized_at: DateTime.now)
      @current_user = user
      session[:user_id] = user.id
      redirect_to root_path, notice: I18n.t('flash.logged_in')
    else
      if user
        UserAuthentication.create!(ip: request.remote_ip, successful: false, user_id: user.id)
      end
      flash.now.alert = I18n.t('flash.bad_authentication')
      render 'new'
    end
  end

  def destroy
    session[:user_id] = session[:impersonator_id] = session[:verifying_user_id] = nil
    redirect_to root_path, notice: I18n.t('flash.logged_out')
  end

  def recover
    @user = User.identified_by(params[:email])

    if params[:email].blank? || @user.blank?
      redirect_to new_session_path, alert: I18n.t('flash.recover_error')
      return
    end

    if @user.expired?
      redirect_to new_session_path, alert: I18n.t('flash.recover_expiration_error')
      return
    end

    begin
      UserPasswordRecoverWorker.perform_async @user.id, @user.update_password
    rescue Exception => e
      redirect_to new_session_path, alert: I18n.t('flash.recover_error')
      return
    end

    redirect_to new_session_path, notice: I18n.t('flash.recovered')
  end
end
