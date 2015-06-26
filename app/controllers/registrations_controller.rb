class RegistrationsController < ApplicationController
  layout 'unauthorized'
  
  skip_before_action :require_login
  skip_after_action :verify_authorized

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @current_user = user
      session[:user_id] = user.id
      redirect_to root_path
    else
      render action: :new
    end
  end

protected

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :integrations_username, :email, :jobs_title, :company_name, :home_region
    )
  end
end