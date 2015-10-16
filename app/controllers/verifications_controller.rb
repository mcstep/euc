class VerificationsController < ApplicationController
  layout false
  
  skip_before_action :require_login
  skip_after_action :verify_authorized

  before_action :require_unverified_user

  def create
    @user.assign_attributes(verification_params)

    if @user.save
      UserVerifyWorker.perform_async(@user.id)
    else
      render action: :new
    end
  end

  def update
    if params[:code] == @user.verification_token
      @user.verify!
      redirect_to new_session_path, notice: I18n.t('flash.user_verified')
    else
      render action: :create
    end
  end

protected

  def require_unverified_user
    @user = User.find(params[:user_id])
    redirect_to new_session_path unless params[:token] == @user.verification_token_hash
  end

  def verification_params
    params.require(:user).permit(:phone)
  end
end
