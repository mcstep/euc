class ProfilesController < ApplicationController
  skip_after_action :verify_authorized

  def accept_airwatch_eula
    current_user.accept_airwatch_eula!
    redirect_back_or_root
  end

  def update
    current_user.update_attributes(profile_params)
    redirect_back_or_root
  end

  def update_password
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

protected

  def profile_params
    params.require(:user).permit(
      :avatar, :avatar_data_uri, :remove_avatar
    )
  end
end
