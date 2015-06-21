class RegistrationCodesController < ApplicationController
  def index
    authorize :registration_code
    @registration_codes = RegistrationCode.all
  end

  def show
    @registration_code = RegistrationCode.find(params[:id])
    authorize @registration_code
  end

  def new
    @registration_code = RegistrationCode.new
    authorize @registration_code
  end

  def edit
    @registration_code = RegistrationCode.find(params[:id])
    authorize @registration_code
  end

  def create
    @registration_code = RegistrationCode.new(registration_code_params)
    authorize @registration_code

    if @registration_code.save
      redirect_to @registration_code
    else
      render :new
    end
  end

  def update
    @registration_code = RegistrationCode.find(params[:id])
    authorize @registration_code

    if @registration_code.update_attributes(registration_code_params)
      redirect_to @registration_code
    else
      render :edit
    end
  end

  def destroy
    @registration_code = RegistrationCode.find(params[:id])
    authorize @registration_code
    @registration_code.destroy

    redirect_to action: :index
  end

private

  def registration_code_params
    params.require(:registration_code).permit(
      :user_role, :user_validity, :valid_from, :valid_to, :total_registrations
    )
  end
end
