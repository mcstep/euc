class RegistrationsController < ApplicationController
  layout 'unauthorized'
  
  skip_before_action :require_login
  skip_after_action :verify_authorized

  def new
    @user = User.new(registration_code_code: params[:code])
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to new_session_path, notice: I18n.t('flash.user_created')
    else
      render action: :new
    end
  end

  def suggest_company
    render json: Company.where('LOWER(name) LIKE LOWER(?)', "#{params[:query]}%").pluck(:name)
  end

protected

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :integrations_username, :email, :job_title, :company_name, :home_region,
      :desired_password, :desired_password_confirmation, :registration_code_code
    )
  end
end